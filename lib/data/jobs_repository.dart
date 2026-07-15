// lib/data/jobs_repository.dart

import 'package:careerhub_mobile/models/job.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'job_dto.dart';
import 'package:careerhub_mobile/data/api_result.dart';

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
  return JobsRepository(ref.watch(dioProvider));
}

// Receives Dio through its constructor rather than importing Riverpod directly, keeping it
// independently testable and swappable.
class JobsRepository {
  final Dio _dio;

  JobsRepository(this._dio);


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

Future<ApiResult<List<Job>>> getJobs() async {
    try {
      final response = await _dio.get('/api/v1/jobs/all');

      final (:jobs, :totalCount, :hasNextPage) =
          _parseJobsResponse(response.data as Map<String, dynamic>);

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