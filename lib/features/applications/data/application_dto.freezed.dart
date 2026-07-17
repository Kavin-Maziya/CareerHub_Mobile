// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApplicationDto {

 String get id; String get jobListingId; String get applicantId; String get jobTitle; String get applicantName; String get email; String? get phone; int get yearsOfExperience; String get coverLetter; String? get linkedInUrl; bool get availableImmediately; int get noticePeriodWeeks; DateTime get submittedAt; String get status;
/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationDtoCopyWith<ApplicationDto> get copyWith => _$ApplicationDtoCopyWithImpl<ApplicationDto>(this as ApplicationDto, _$identity);

  /// Serializes this ApplicationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.jobListingId, jobListingId) || other.jobListingId == jobListingId)&&(identical(other.applicantId, applicantId) || other.applicantId == applicantId)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.applicantName, applicantName) || other.applicantName == applicantName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.coverLetter, coverLetter) || other.coverLetter == coverLetter)&&(identical(other.linkedInUrl, linkedInUrl) || other.linkedInUrl == linkedInUrl)&&(identical(other.availableImmediately, availableImmediately) || other.availableImmediately == availableImmediately)&&(identical(other.noticePeriodWeeks, noticePeriodWeeks) || other.noticePeriodWeeks == noticePeriodWeeks)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,jobListingId,applicantId,jobTitle,applicantName,email,phone,yearsOfExperience,coverLetter,linkedInUrl,availableImmediately,noticePeriodWeeks,submittedAt,status);

@override
String toString() {
  return 'ApplicationDto(id: $id, jobListingId: $jobListingId, applicantId: $applicantId, jobTitle: $jobTitle, applicantName: $applicantName, email: $email, phone: $phone, yearsOfExperience: $yearsOfExperience, coverLetter: $coverLetter, linkedInUrl: $linkedInUrl, availableImmediately: $availableImmediately, noticePeriodWeeks: $noticePeriodWeeks, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $ApplicationDtoCopyWith<$Res>  {
  factory $ApplicationDtoCopyWith(ApplicationDto value, $Res Function(ApplicationDto) _then) = _$ApplicationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String jobListingId, String applicantId, String jobTitle, String applicantName, String email, String? phone, int yearsOfExperience, String coverLetter, String? linkedInUrl, bool availableImmediately, int noticePeriodWeeks, DateTime submittedAt, String status
});




}
/// @nodoc
class _$ApplicationDtoCopyWithImpl<$Res>
    implements $ApplicationDtoCopyWith<$Res> {
  _$ApplicationDtoCopyWithImpl(this._self, this._then);

  final ApplicationDto _self;
  final $Res Function(ApplicationDto) _then;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? jobListingId = null,Object? applicantId = null,Object? jobTitle = null,Object? applicantName = null,Object? email = null,Object? phone = freezed,Object? yearsOfExperience = null,Object? coverLetter = null,Object? linkedInUrl = freezed,Object? availableImmediately = null,Object? noticePeriodWeeks = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobListingId: null == jobListingId ? _self.jobListingId : jobListingId // ignore: cast_nullable_to_non_nullable
as String,applicantId: null == applicantId ? _self.applicantId : applicantId // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,applicantName: null == applicantName ? _self.applicantName : applicantName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,coverLetter: null == coverLetter ? _self.coverLetter : coverLetter // ignore: cast_nullable_to_non_nullable
as String,linkedInUrl: freezed == linkedInUrl ? _self.linkedInUrl : linkedInUrl // ignore: cast_nullable_to_non_nullable
as String?,availableImmediately: null == availableImmediately ? _self.availableImmediately : availableImmediately // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodWeeks: null == noticePeriodWeeks ? _self.noticePeriodWeeks : noticePeriodWeeks // ignore: cast_nullable_to_non_nullable
as int,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApplicationDto].
extension ApplicationDtoPatterns on ApplicationDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationDto value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String jobListingId,  String applicantId,  String jobTitle,  String applicantName,  String email,  String? phone,  int yearsOfExperience,  String coverLetter,  String? linkedInUrl,  bool availableImmediately,  int noticePeriodWeeks,  DateTime submittedAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that.id,_that.jobListingId,_that.applicantId,_that.jobTitle,_that.applicantName,_that.email,_that.phone,_that.yearsOfExperience,_that.coverLetter,_that.linkedInUrl,_that.availableImmediately,_that.noticePeriodWeeks,_that.submittedAt,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String jobListingId,  String applicantId,  String jobTitle,  String applicantName,  String email,  String? phone,  int yearsOfExperience,  String coverLetter,  String? linkedInUrl,  bool availableImmediately,  int noticePeriodWeeks,  DateTime submittedAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _ApplicationDto():
return $default(_that.id,_that.jobListingId,_that.applicantId,_that.jobTitle,_that.applicantName,_that.email,_that.phone,_that.yearsOfExperience,_that.coverLetter,_that.linkedInUrl,_that.availableImmediately,_that.noticePeriodWeeks,_that.submittedAt,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String jobListingId,  String applicantId,  String jobTitle,  String applicantName,  String email,  String? phone,  int yearsOfExperience,  String coverLetter,  String? linkedInUrl,  bool availableImmediately,  int noticePeriodWeeks,  DateTime submittedAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationDto() when $default != null:
return $default(_that.id,_that.jobListingId,_that.applicantId,_that.jobTitle,_that.applicantName,_that.email,_that.phone,_that.yearsOfExperience,_that.coverLetter,_that.linkedInUrl,_that.availableImmediately,_that.noticePeriodWeeks,_that.submittedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplicationDto implements ApplicationDto {
  const _ApplicationDto({required this.id, required this.jobListingId, required this.applicantId, required this.jobTitle, required this.applicantName, required this.email, this.phone, required this.yearsOfExperience, required this.coverLetter, this.linkedInUrl, required this.availableImmediately, required this.noticePeriodWeeks, required this.submittedAt, required this.status});
  factory _ApplicationDto.fromJson(Map<String, dynamic> json) => _$ApplicationDtoFromJson(json);

@override final  String id;
@override final  String jobListingId;
@override final  String applicantId;
@override final  String jobTitle;
@override final  String applicantName;
@override final  String email;
@override final  String? phone;
@override final  int yearsOfExperience;
@override final  String coverLetter;
@override final  String? linkedInUrl;
@override final  bool availableImmediately;
@override final  int noticePeriodWeeks;
@override final  DateTime submittedAt;
@override final  String status;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationDtoCopyWith<_ApplicationDto> get copyWith => __$ApplicationDtoCopyWithImpl<_ApplicationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplicationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.jobListingId, jobListingId) || other.jobListingId == jobListingId)&&(identical(other.applicantId, applicantId) || other.applicantId == applicantId)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.applicantName, applicantName) || other.applicantName == applicantName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.coverLetter, coverLetter) || other.coverLetter == coverLetter)&&(identical(other.linkedInUrl, linkedInUrl) || other.linkedInUrl == linkedInUrl)&&(identical(other.availableImmediately, availableImmediately) || other.availableImmediately == availableImmediately)&&(identical(other.noticePeriodWeeks, noticePeriodWeeks) || other.noticePeriodWeeks == noticePeriodWeeks)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,jobListingId,applicantId,jobTitle,applicantName,email,phone,yearsOfExperience,coverLetter,linkedInUrl,availableImmediately,noticePeriodWeeks,submittedAt,status);

@override
String toString() {
  return 'ApplicationDto(id: $id, jobListingId: $jobListingId, applicantId: $applicantId, jobTitle: $jobTitle, applicantName: $applicantName, email: $email, phone: $phone, yearsOfExperience: $yearsOfExperience, coverLetter: $coverLetter, linkedInUrl: $linkedInUrl, availableImmediately: $availableImmediately, noticePeriodWeeks: $noticePeriodWeeks, submittedAt: $submittedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ApplicationDtoCopyWith<$Res> implements $ApplicationDtoCopyWith<$Res> {
  factory _$ApplicationDtoCopyWith(_ApplicationDto value, $Res Function(_ApplicationDto) _then) = __$ApplicationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String jobListingId, String applicantId, String jobTitle, String applicantName, String email, String? phone, int yearsOfExperience, String coverLetter, String? linkedInUrl, bool availableImmediately, int noticePeriodWeeks, DateTime submittedAt, String status
});




}
/// @nodoc
class __$ApplicationDtoCopyWithImpl<$Res>
    implements _$ApplicationDtoCopyWith<$Res> {
  __$ApplicationDtoCopyWithImpl(this._self, this._then);

  final _ApplicationDto _self;
  final $Res Function(_ApplicationDto) _then;

/// Create a copy of ApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? jobListingId = null,Object? applicantId = null,Object? jobTitle = null,Object? applicantName = null,Object? email = null,Object? phone = freezed,Object? yearsOfExperience = null,Object? coverLetter = null,Object? linkedInUrl = freezed,Object? availableImmediately = null,Object? noticePeriodWeeks = null,Object? submittedAt = null,Object? status = null,}) {
  return _then(_ApplicationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobListingId: null == jobListingId ? _self.jobListingId : jobListingId // ignore: cast_nullable_to_non_nullable
as String,applicantId: null == applicantId ? _self.applicantId : applicantId // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,applicantName: null == applicantName ? _self.applicantName : applicantName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,coverLetter: null == coverLetter ? _self.coverLetter : coverLetter // ignore: cast_nullable_to_non_nullable
as String,linkedInUrl: freezed == linkedInUrl ? _self.linkedInUrl : linkedInUrl // ignore: cast_nullable_to_non_nullable
as String?,availableImmediately: null == availableImmediately ? _self.availableImmediately : availableImmediately // ignore: cast_nullable_to_non_nullable
as bool,noticePeriodWeeks: null == noticePeriodWeeks ? _self.noticePeriodWeeks : noticePeriodWeeks // ignore: cast_nullable_to_non_nullable
as int,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
