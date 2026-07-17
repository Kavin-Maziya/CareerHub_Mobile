import 'package:freezed_annotation/freezed_annotation.dart';

part 'application_dto.freezed.dart';
part 'application_dto.g.dart';

@freezed
abstract class ApplicationDto with _$ApplicationDto {
  const factory ApplicationDto({
    required String id,
    required String jobListingId,
    required String applicantId,
    required String jobTitle,
    required String applicantName,
    required String email,
    String? phone,
    required int yearsOfExperience,
    required String coverLetter,
    String? linkedInUrl,
    required bool availableImmediately,
    required int noticePeriodWeeks,
    required DateTime submittedAt,
    required String status,
  }) = _ApplicationDto;

  factory ApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$ApplicationDtoFromJson(json);
}