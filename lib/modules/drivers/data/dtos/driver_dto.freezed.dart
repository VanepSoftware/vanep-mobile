// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverDto {

 String get token; String get name;@JsonKey(name: 'photo') String? get photoUrl; double? get rating; int? get experienceYears; String? get city;
/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverDtoCopyWith<DriverDto> get copyWith => _$DriverDtoCopyWithImpl<DriverDto>(this as DriverDto, _$identity);

  /// Serializes this DriverDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverDto&&(identical(other.token, token) || other.token == token)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,name,photoUrl,rating,experienceYears,city);

@override
String toString() {
  return 'DriverDto(token: $token, name: $name, photoUrl: $photoUrl, rating: $rating, experienceYears: $experienceYears, city: $city)';
}


}

/// @nodoc
abstract mixin class $DriverDtoCopyWith<$Res>  {
  factory $DriverDtoCopyWith(DriverDto value, $Res Function(DriverDto) _then) = _$DriverDtoCopyWithImpl;
@useResult
$Res call({
 String token, String name,@JsonKey(name: 'photo') String? photoUrl, double? rating, int? experienceYears, String? city
});




}
/// @nodoc
class _$DriverDtoCopyWithImpl<$Res>
    implements $DriverDtoCopyWith<$Res> {
  _$DriverDtoCopyWithImpl(this._self, this._then);

  final DriverDto _self;
  final $Res Function(DriverDto) _then;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? name = null,Object? photoUrl = freezed,Object? rating = freezed,Object? experienceYears = freezed,Object? city = freezed,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverDto].
extension DriverDtoPatterns on DriverDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverDto value)  $default,){
final _that = this;
switch (_that) {
case _DriverDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverDto value)?  $default,){
final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String name, @JsonKey(name: 'photo')  String? photoUrl,  double? rating,  int? experienceYears,  String? city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
return $default(_that.token,_that.name,_that.photoUrl,_that.rating,_that.experienceYears,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String name, @JsonKey(name: 'photo')  String? photoUrl,  double? rating,  int? experienceYears,  String? city)  $default,) {final _that = this;
switch (_that) {
case _DriverDto():
return $default(_that.token,_that.name,_that.photoUrl,_that.rating,_that.experienceYears,_that.city);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String name, @JsonKey(name: 'photo')  String? photoUrl,  double? rating,  int? experienceYears,  String? city)?  $default,) {final _that = this;
switch (_that) {
case _DriverDto() when $default != null:
return $default(_that.token,_that.name,_that.photoUrl,_that.rating,_that.experienceYears,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverDto implements DriverDto {
  const _DriverDto({required this.token, required this.name, @JsonKey(name: 'photo') this.photoUrl, this.rating, this.experienceYears, this.city});
  factory _DriverDto.fromJson(Map<String, dynamic> json) => _$DriverDtoFromJson(json);

@override final  String token;
@override final  String name;
@override@JsonKey(name: 'photo') final  String? photoUrl;
@override final  double? rating;
@override final  int? experienceYears;
@override final  String? city;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverDtoCopyWith<_DriverDto> get copyWith => __$DriverDtoCopyWithImpl<_DriverDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverDto&&(identical(other.token, token) || other.token == token)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,name,photoUrl,rating,experienceYears,city);

@override
String toString() {
  return 'DriverDto(token: $token, name: $name, photoUrl: $photoUrl, rating: $rating, experienceYears: $experienceYears, city: $city)';
}


}

/// @nodoc
abstract mixin class _$DriverDtoCopyWith<$Res> implements $DriverDtoCopyWith<$Res> {
  factory _$DriverDtoCopyWith(_DriverDto value, $Res Function(_DriverDto) _then) = __$DriverDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String name,@JsonKey(name: 'photo') String? photoUrl, double? rating, int? experienceYears, String? city
});




}
/// @nodoc
class __$DriverDtoCopyWithImpl<$Res>
    implements _$DriverDtoCopyWith<$Res> {
  __$DriverDtoCopyWithImpl(this._self, this._then);

  final _DriverDto _self;
  final $Res Function(_DriverDto) _then;

/// Create a copy of DriverDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? name = null,Object? photoUrl = freezed,Object? rating = freezed,Object? experienceYears = freezed,Object? city = freezed,}) {
  return _then(_DriverDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
