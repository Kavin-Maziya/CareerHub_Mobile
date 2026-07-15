// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobDto _$JobDtoFromJson(Map<String, dynamic> json) => _JobDto(
  id: json['id'] as String,
  title: json['title'] as String,
  companyName: json['companyName'] as String,
  location: json['location'] as String,
  description: json['description'] as String,
  postedAt: DateTime.parse(json['postedAt'] as String),
  salaryDisplay: json['salaryDisplay'] as String,
  closingDate: DateTime.parse(json['closingDate'] as String),
  applicationCount: (json['applicationCount'] as num).toInt(),
  isActive: json['isActive'] as bool,
  employmentType: json['employmentType'] as String,
);

Map<String, dynamic> _$JobDtoToJson(_JobDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'companyName': instance.companyName,
  'location': instance.location,
  'description': instance.description,
  'postedAt': instance.postedAt.toIso8601String(),
  'salaryDisplay': instance.salaryDisplay,
  'closingDate': instance.closingDate.toIso8601String(),
  'applicationCount': instance.applicationCount,
  'isActive': instance.isActive,
  'employmentType': instance.employmentType,
};
