// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Job {

 String get id; String get title; String get company; String get location; String get description; EmploymentType get employmentType; bool get isOpen; String? get salaryDisplay; DateTime? get closingDate;
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCopyWith<Job> get copyWith => _$JobCopyWithImpl<Job>(this as Job, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Job&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.salaryDisplay, salaryDisplay) || other.salaryDisplay == salaryDisplay)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,company,location,description,employmentType,isOpen,salaryDisplay,closingDate);

@override
String toString() {
  return 'Job(id: $id, title: $title, company: $company, location: $location, description: $description, employmentType: $employmentType, isOpen: $isOpen, salaryDisplay: $salaryDisplay, closingDate: $closingDate)';
}


}

/// @nodoc
abstract mixin class $JobCopyWith<$Res>  {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
@useResult
$Res call({
 String id, String title, String company, String location, String description, EmploymentType employmentType, bool isOpen, String? salaryDisplay, DateTime? closingDate
});




}
/// @nodoc
class _$JobCopyWithImpl<$Res>
    implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? company = null,Object? location = null,Object? description = null,Object? employmentType = null,Object? isOpen = null,Object? salaryDisplay = freezed,Object? closingDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,salaryDisplay: freezed == salaryDisplay ? _self.salaryDisplay : salaryDisplay // ignore: cast_nullable_to_non_nullable
as String?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Job value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Job value)  $default,){
final _that = this;
switch (_that) {
case _Job():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Job value)?  $default,){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String company,  String location,  String description,  EmploymentType employmentType,  bool isOpen,  String? salaryDisplay,  DateTime? closingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.title,_that.company,_that.location,_that.description,_that.employmentType,_that.isOpen,_that.salaryDisplay,_that.closingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String company,  String location,  String description,  EmploymentType employmentType,  bool isOpen,  String? salaryDisplay,  DateTime? closingDate)  $default,) {final _that = this;
switch (_that) {
case _Job():
return $default(_that.id,_that.title,_that.company,_that.location,_that.description,_that.employmentType,_that.isOpen,_that.salaryDisplay,_that.closingDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String company,  String location,  String description,  EmploymentType employmentType,  bool isOpen,  String? salaryDisplay,  DateTime? closingDate)?  $default,) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.title,_that.company,_that.location,_that.description,_that.employmentType,_that.isOpen,_that.salaryDisplay,_that.closingDate);case _:
  return null;

}
}

}

/// @nodoc


class _Job extends Job {
  const _Job({required this.id, required this.title, required this.company, required this.location, required this.description, required this.employmentType, required this.isOpen, this.salaryDisplay, this.closingDate}): super._();
  

@override final  String id;
@override final  String title;
@override final  String company;
@override final  String location;
@override final  String description;
@override final  EmploymentType employmentType;
@override final  bool isOpen;
@override final  String? salaryDisplay;
@override final  DateTime? closingDate;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCopyWith<_Job> get copyWith => __$JobCopyWithImpl<_Job>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Job&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.salaryDisplay, salaryDisplay) || other.salaryDisplay == salaryDisplay)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,company,location,description,employmentType,isOpen,salaryDisplay,closingDate);

@override
String toString() {
  return 'Job(id: $id, title: $title, company: $company, location: $location, description: $description, employmentType: $employmentType, isOpen: $isOpen, salaryDisplay: $salaryDisplay, closingDate: $closingDate)';
}


}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) = __$JobCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String company, String location, String description, EmploymentType employmentType, bool isOpen, String? salaryDisplay, DateTime? closingDate
});




}
/// @nodoc
class __$JobCopyWithImpl<$Res>
    implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? company = null,Object? location = null,Object? description = null,Object? employmentType = null,Object? isOpen = null,Object? salaryDisplay = freezed,Object? closingDate = freezed,}) {
  return _then(_Job(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,employmentType: null == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,salaryDisplay: freezed == salaryDisplay ? _self.salaryDisplay : salaryDisplay // ignore: cast_nullable_to_non_nullable
as String?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
