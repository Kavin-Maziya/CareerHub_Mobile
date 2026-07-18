import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:careerhub_mobile/features/applications/models/application_status.dart';
import 'package:careerhub_mobile/features/applications/data/application_dto.dart';

part 'job_application.freezed.dart';

@freezed
abstract class JobApplication with _$JobApplication {
  const JobApplication._();

  const factory JobApplication({
    required String id,
    required String jobTitle,
    required DateTime submittedAt,
    required ApplicationStatus status,
  }) = _JobApplication;

  static JobApplication fromDto(ApplicationDto dto) {
    return JobApplication(
      id: dto.id,
      jobTitle: dto.jobTitle,
      submittedAt: dto.submittedAt,
      status: ApplicationStatus.fromApiValue(dto.status),
    );
  }
}