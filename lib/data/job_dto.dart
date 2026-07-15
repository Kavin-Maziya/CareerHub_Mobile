// Mirrors the CareerHub API's JobListResponse JSON exactly. Captures
// every field the API returns, including ones the Flutter UI doesn't
// currently show (postedAt, applicationCount) 
// This is the only file that knows the API's exact field names.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_dto.freezed.dart';
part 'job_dto.g.dart';

@freezed
abstract class JobDto with _$JobDto {
  const factory JobDto({
    required String id,
    required String title,
    required String companyName,
    required String location,
    required String description,
    required DateTime postedAt,
    required String salaryDisplay,
    required DateTime closingDate,
    required int applicationCount,
    required bool isActive,
    required String employmentType,
  }) = _JobDto;

  factory JobDto.fromJson(Map<String, dynamic> json) =>
      _$JobDtoFromJson(json);
}