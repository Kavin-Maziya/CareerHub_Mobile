// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApplicationDto _$ApplicationDtoFromJson(Map<String, dynamic> json) =>
    _ApplicationDto(
      id: json['id'] as String,
      jobListingId: json['jobListingId'] as String,
      applicantId: json['applicantId'] as String,
      jobTitle: json['jobTitle'] as String,
      applicantName: json['applicantName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      coverLetter: json['coverLetter'] as String,
      linkedInUrl: json['linkedInUrl'] as String?,
      availableImmediately: json['availableImmediately'] as bool,
      noticePeriodWeeks: (json['noticePeriodWeeks'] as num).toInt(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ApplicationDtoToJson(_ApplicationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobListingId': instance.jobListingId,
      'applicantId': instance.applicantId,
      'jobTitle': instance.jobTitle,
      'applicantName': instance.applicantName,
      'email': instance.email,
      'phone': instance.phone,
      'yearsOfExperience': instance.yearsOfExperience,
      'coverLetter': instance.coverLetter,
      'linkedInUrl': instance.linkedInUrl,
      'availableImmediately': instance.availableImmediately,
      'noticePeriodWeeks': instance.noticePeriodWeeks,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'status': instance.status,
    };
