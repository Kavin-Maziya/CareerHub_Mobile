import 'package:careerhub_mobile/features/data/application_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'application_status.dart';


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