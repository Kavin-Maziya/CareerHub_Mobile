// lib/data/jobs_repository.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/job.dart';
import 'job_dto.dart';

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

Future<List<Job>> getJobs() async {
  final response = await _dio.get('/api/v1/jobs/all');

  // Named record destructuring -- binds all three parsed values to
  // clearly named variables at the call site.
  final (:jobs, :totalCount, :hasNextPage) =
      _parseJobsResponse(response.data as Map<String, dynamic>);

  // totalCount and hasNextPage currently not used by getJobs() yet, but are
  // now available for a future pull-to-refresh / pagination feature
  // (Assignment 2.1 Stretch A) without needing to touch this parsing logic again.
  return jobs;
}
}