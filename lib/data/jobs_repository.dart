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

  Future<List<Job>> getJobs() async {
    final response = await _dio.get('/api/v1/jobs/all');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => JobDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => Job.fromDto(dto))
        .toList();
  }
}