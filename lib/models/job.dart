// Core domain model for a CareerHub job listing. Freezed-generated
// ==, hashCode, copyWith, and toString give every Job instance real
// value equality instead of Dart's default identity comparison.

import 'package:careerhub_mobile/data/job_dto.dart';
import 'package:careerhub_mobile/models/employment_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';

@freezed
abstract class Job with _$Job {
  // Required so Freezed's generated mixin has a constructor path to
  // attach custom members (canApply, displaySalary) to -- without this,
  // build_runner cannot generate the class correctly.
  const Job._();

  const factory Job({
    required String id,
    required String title,
    required String company,
    required String location,
    required String description,
    required EmploymentType employmentType,
    required bool isOpen,
    String? salaryDisplay,
    DateTime? closingDate,
  }) = _Job;

  // Converted from a factory constructor to a static method. Freezed
  // treats every factory constructor as a potential union-type variant,
  // so Job.fromDto would collide with that interpretation if left as a
  // factory. The call site (Job.fromDto(dto)) is unchanged, since Dart's
  // dot-syntax for a named constructor and a static method are
  // identical at the call site.
  static Job fromDto(JobDto dto) {
    return Job(
      id: dto.id,
      title: dto.title,
      company: dto.companyName, // API: companyName -> Flutter: company
      location: dto.location,
      description: dto.description,
      employmentType: EmploymentType.fromApiValue(dto.employmentType),
      isOpen: dto.isActive, // API: isActive -> Flutter: isOpen
      salaryDisplay:
          dto.salaryDisplay.trim().isEmpty ? null : dto.salaryDisplay,
      closingDate: dto.closingDate,
    );
  }

  // Converted from a named generative constructor to a static method.
  // Job's fields are abstract getters implemented only by the generated
  // _Job class -- there's no way for a second generative constructor on
  // the abstract Job class to assign to them directly, so this can only
  // survive as a static helper that calls the primary factory.
  static Job closed({
    required String id,
    required String title,
    required String company,
    required String location,
    required String description,
    required EmploymentType employmentType,
    String? salaryDisplay,
    DateTime? closingDate,
  }) {
    return Job(
      id: id,
      title: title,
      company: company,
      location: location,
      description: description,
      employmentType: employmentType,
      isOpen: false,
      salaryDisplay: salaryDisplay,
      closingDate: closingDate,
    );
  }

  // Same conversion as Job.closed -- static method instead of a named
  // generative constructor, for the same reason.
  static Job remote({
    required String id,
    required String title,
    required String company,
    required String description,
    required EmploymentType employmentType,
    required bool isOpen,
    String? salaryDisplay,
    DateTime? closingDate,
  }) {
    return Job(
      id: id,
      title: title,
      company: company,
      location: 'Remote',
      description: description,
      employmentType: employmentType,
      isOpen: isOpen,
      salaryDisplay: salaryDisplay,
      closingDate: closingDate,
    );
  }

  bool get canApply => isOpen;

  String get displaySalary => salaryDisplay ?? 'Market-related';

  // Custom toString removed -- Freezed's generated mixin already
  // provides a toString listing every field, satisfying the same
  // debugging need without hand-written string interpolation.
}