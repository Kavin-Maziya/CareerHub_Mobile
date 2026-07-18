
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/api_result.dart';
import '../../../data/jobs_repository.dart' show dioProvider;
import '../../../main.dart' show isarProvider;
import '../models/job_application.dart';
import '../models/application_status.dart';
import 'application_dto.dart';
import 'application_cache_entry.dart';

part 'applications_repository.g.dart';

// Hardcoded test applicant
const _testApplicantId = 'bbbbbbbb-0000-0000-0000-000000000001';

@riverpod
ApplicationsRepository applicationsRepository(Ref ref) {
  return ApplicationsRepository(
    ref.watch(dioProvider),
    ref.watch(isarProvider),
  );
}

class ApplicationsRepository {
  final Dio _dio;
  final Isar _isar;

  ApplicationsRepository(this._dio, this._isar);

  // Reads from Isar only -- no network call. Used for instant display
  // on cold boot, and as the fallback when a network fetch fails.
  Future<List<JobApplication>> getCachedApplications() async {
    final entries = await _isar.applicationCacheEntrys.where().findAll();

    return entries
        .map((entry) => JobApplication(
              id: entry.applicationId,
              jobTitle: entry.jobTitle,
              submittedAt: entry.submittedAt,
              status: ApplicationStatus.fromApiValue(entry.status),
            ))
        .toList();
  }

  // Fetches from the API, writes the result to Isar atomically inside a
  // write transaction, and returns an ApiResult wrapping the list.
  Future<ApiResult<List<JobApplication>>> fetchAndCacheApplications() async {
    try {
      final response =
          await _dio.get('/api/v1/applications/applicant/$_testApplicantId');

      final data = response.data as List<dynamic>;
      final applications = data
          .map((json) =>
              ApplicationDto.fromJson(json as Map<String, dynamic>))
          .map((dto) => JobApplication.fromDto(dto))
          .toList();

      // Atomic write -- either every entry is written, or none are, so
      // the cache is never left in a partially-updated state.
      await _isar.writeTxn(() async {
        await _isar.applicationCacheEntrys.clear();
        await _isar.applicationCacheEntrys.putAll(
          applications
              .map((app) => ApplicationCacheEntry()
                ..applicationId = app.id
                ..jobTitle = app.jobTitle
                ..submittedAt = app.submittedAt
                ..status = _statusToApiValue(app.status))
              .toList(),
        );
      });

      return Success(applications);
    } on DioException catch (e) {
      return Failure(
        _messageForDioException(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return const Failure('Something went wrong. Please try again.');
    }
  }

  String _statusToApiValue(ApplicationStatus status) => switch (status) {
        ApplicationStatus.submitted => 'Submitted',
        ApplicationStatus.underReview => 'UnderReview',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.offered => 'Offered',
        ApplicationStatus.rejected => 'Rejected',
      };

  String _messageForDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The connection timed out. Please check your network and try again.',
      DioExceptionType.connectionError =>
        'Could not connect to the server. Please check your network.',
      DioExceptionType.badResponse =>
        'The server responded with an error (${e.response?.statusCode ?? 'unknown'}).',
      DioExceptionType.cancel => 'The request was cancelled.',
      _ => 'An unexpected network error occurred. Please try again.',
    };
  }
}