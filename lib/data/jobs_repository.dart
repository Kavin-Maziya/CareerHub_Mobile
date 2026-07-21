// lib/data/jobs_repository.dart

import 'package:careerhub_mobile/models/employment_type.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'job_dto.dart';
import 'package:careerhub_mobile/data/api_result.dart';
import 'package:careerhub_mobile/core/isar_provider.dart';
import 'package:careerhub_mobile/data/job_cache.dart';
import 'package:isar_community/isar.dart';

part 'jobs_repository.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        // Android emulator's alias for the host machine's localhost.
        defaultValue: 'http://10.0.2.2:5059',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(LogInterceptor(responseBody: true));
  return dio;
}

@riverpod
JobsRepository jobsRepository(Ref ref) {
  return JobsRepository(
    ref.watch(dioProvider),
    ref.watch(isarProvider),
  );
}

// Receives Dio through its constructor rather than importing Riverpod directly, keeping it
// independently testable and swappable.
class JobsRepository {
 final Dio _dio;
final Isar _isar;

JobsRepository(
  this._dio,
  this._isar,
);

JobCache _toCache(Job job) {
  final cache = JobCache();

  cache.jobId = job.id;
  cache.title = job.title;
  cache.company = job.company;
  cache.location = job.location;
  cache.description = job.description;
  cache.employmentType = job.employmentType.name;
  cache.isOpen = job.isOpen;
  cache.salaryDisplay = job.salaryDisplay;
  cache.closingDate = job.closingDate;

  return cache;
}

Job _fromCache(JobCache cache) {
  return Job(
    id: cache.jobId,
    title: cache.title,
    company: cache.company,
    location: cache.location,
    description: cache.description,
    employmentType: EmploymentType.values.firstWhere(
      (e) => e.name == cache.employmentType,
      orElse: () => EmploymentType.fullTime,
    ),
    isOpen: cache.isOpen,
    salaryDisplay: cache.salaryDisplay,
    closingDate: cache.closingDate,
  );
}

({List<Job> jobs, int totalCount, bool hasNextPage}) _parseJobsResponse(
  Map<String, dynamic> responseData,
) {
  final data = responseData['data'] as List<dynamic>;
  final jobs = data
      .map((json) => JobDto.fromJson(json as Map<String, dynamic>))
      .map((dto) => Job.fromDto(dto))
      .toList();

  return (
    jobs: jobs,
    totalCount: responseData['totalCount'] as int,
    hasNextPage: responseData['hasNextPage'] as bool,
  );
}

Future<List<Job>> getCachedJobs() async {
  final cachedJobs = await _isar.jobCaches.where().findAll();

  return cachedJobs.map(_fromCache).toList();
}

Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get('/api/v1/jobs/all');

      final (:jobs, :totalCount, :hasNextPage) =
          _parseJobsResponse(response.data as Map<String, dynamic>);
          
await _isar.writeTxn(() async {
  await _isar.jobCaches.clear();
  await _isar.jobCaches.putAll(
    jobs.map(_toCache).toList(),
  );
});
      return Success(jobs);
    } on DioException catch (e) {
      return Failure(_messageForDioException(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return const Failure('Something went wrong. Please try again.');
    }
  }

  // Private method on the repository class -- maps a DioException's
  // type to a human-readable message via a switch expression.
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