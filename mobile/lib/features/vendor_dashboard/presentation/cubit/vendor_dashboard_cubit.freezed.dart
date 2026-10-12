// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_dashboard_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VendorDashboardState {

 bool get loading; String? get error; Map<String, dynamic>? get me; Map<String, dynamic>? get earnings; Map<String, dynamic>? get reviews;
/// Create a copy of VendorDashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorDashboardStateCopyWith<VendorDashboardState> get copyWith => _$VendorDashboardStateCopyWithImpl<VendorDashboardState>(this as VendorDashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorDashboardState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.me, me)&&const DeepCollectionEquality().equals(other.earnings, earnings)&&const DeepCollectionEquality().equals(other.reviews, reviews));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(me),const DeepCollectionEquality().hash(earnings),const DeepCollectionEquality().hash(reviews));

@override
String toString() {
  return 'VendorDashboardState(loading: $loading, error: $error, me: $me, earnings: $earnings, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class $VendorDashboardStateCopyWith<$Res>  {
  factory $VendorDashboardStateCopyWith(VendorDashboardState value, $Res Function(VendorDashboardState) _then) = _$VendorDashboardStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, Map<String, dynamic>? me, Map<String, dynamic>? earnings, Map<String, dynamic>? reviews
});




}
/// @nodoc
class _$VendorDashboardStateCopyWithImpl<$Res>
    implements $VendorDashboardStateCopyWith<$Res> {
  _$VendorDashboardStateCopyWithImpl(this._self, this._then);

  final VendorDashboardState _self;
  final $Res Function(VendorDashboardState) _then;

/// Create a copy of VendorDashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? me = freezed,Object? earnings = freezed,Object? reviews = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,me: freezed == me ? _self.me : me // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,earnings: freezed == earnings ? _self.earnings : earnings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reviews: freezed == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorDashboardState].
extension VendorDashboardStatePatterns on VendorDashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorDashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorDashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorDashboardState value)  $default,){
final _that = this;
switch (_that) {
case _VendorDashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorDashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _VendorDashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  Map<String, dynamic>? me,  Map<String, dynamic>? earnings,  Map<String, dynamic>? reviews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorDashboardState() when $default != null:
return $default(_that.loading,_that.error,_that.me,_that.earnings,_that.reviews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  Map<String, dynamic>? me,  Map<String, dynamic>? earnings,  Map<String, dynamic>? reviews)  $default,) {final _that = this;
switch (_that) {
case _VendorDashboardState():
return $default(_that.loading,_that.error,_that.me,_that.earnings,_that.reviews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  Map<String, dynamic>? me,  Map<String, dynamic>? earnings,  Map<String, dynamic>? reviews)?  $default,) {final _that = this;
switch (_that) {
case _VendorDashboardState() when $default != null:
return $default(_that.loading,_that.error,_that.me,_that.earnings,_that.reviews);case _:
  return null;

}
}

}

/// @nodoc


class _VendorDashboardState implements VendorDashboardState {
  const _VendorDashboardState({this.loading = false, this.error, final  Map<String, dynamic>? me, final  Map<String, dynamic>? earnings, final  Map<String, dynamic>? reviews}): _me = me,_earnings = earnings,_reviews = reviews;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  Map<String, dynamic>? _me;
@override Map<String, dynamic>? get me {
  final value = _me;
  if (value == null) return null;
  if (_me is EqualUnmodifiableMapView) return _me;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _earnings;
@override Map<String, dynamic>? get earnings {
  final value = _earnings;
  if (value == null) return null;
  if (_earnings is EqualUnmodifiableMapView) return _earnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _reviews;
@override Map<String, dynamic>? get reviews {
  final value = _reviews;
  if (value == null) return null;
  if (_reviews is EqualUnmodifiableMapView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of VendorDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorDashboardStateCopyWith<_VendorDashboardState> get copyWith => __$VendorDashboardStateCopyWithImpl<_VendorDashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorDashboardState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._me, _me)&&const DeepCollectionEquality().equals(other._earnings, _earnings)&&const DeepCollectionEquality().equals(other._reviews, _reviews));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_me),const DeepCollectionEquality().hash(_earnings),const DeepCollectionEquality().hash(_reviews));

@override
String toString() {
  return 'VendorDashboardState(loading: $loading, error: $error, me: $me, earnings: $earnings, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class _$VendorDashboardStateCopyWith<$Res> implements $VendorDashboardStateCopyWith<$Res> {
  factory _$VendorDashboardStateCopyWith(_VendorDashboardState value, $Res Function(_VendorDashboardState) _then) = __$VendorDashboardStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, Map<String, dynamic>? me, Map<String, dynamic>? earnings, Map<String, dynamic>? reviews
});




}
/// @nodoc
class __$VendorDashboardStateCopyWithImpl<$Res>
    implements _$VendorDashboardStateCopyWith<$Res> {
  __$VendorDashboardStateCopyWithImpl(this._self, this._then);

  final _VendorDashboardState _self;
  final $Res Function(_VendorDashboardState) _then;

/// Create a copy of VendorDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? me = freezed,Object? earnings = freezed,Object? reviews = freezed,}) {
  return _then(_VendorDashboardState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,me: freezed == me ? _self._me : me // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,earnings: freezed == earnings ? _self._earnings : earnings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reviews: freezed == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
