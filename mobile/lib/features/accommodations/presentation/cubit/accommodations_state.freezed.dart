// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accommodations_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccommodationsState {

 bool get loading; String? get error; List<AccommodationsItem> get items; AccommodationsItem? get detail;
/// Create a copy of AccommodationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccommodationsStateCopyWith<AccommodationsState> get copyWith => _$AccommodationsStateCopyWithImpl<AccommodationsState>(this as AccommodationsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccommodationsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'AccommodationsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $AccommodationsStateCopyWith<$Res>  {
  factory $AccommodationsStateCopyWith(AccommodationsState value, $Res Function(AccommodationsState) _then) = _$AccommodationsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<AccommodationsItem> items, AccommodationsItem? detail
});




}
/// @nodoc
class _$AccommodationsStateCopyWithImpl<$Res>
    implements $AccommodationsStateCopyWith<$Res> {
  _$AccommodationsStateCopyWithImpl(this._self, this._then);

  final AccommodationsState _self;
  final $Res Function(AccommodationsState) _then;

/// Create a copy of AccommodationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AccommodationsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as AccommodationsItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccommodationsState].
extension AccommodationsStatePatterns on AccommodationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccommodationsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccommodationsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccommodationsState value)  $default,){
final _that = this;
switch (_that) {
case _AccommodationsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccommodationsState value)?  $default,){
final _that = this;
switch (_that) {
case _AccommodationsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<AccommodationsItem> items,  AccommodationsItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccommodationsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<AccommodationsItem> items,  AccommodationsItem? detail)  $default,) {final _that = this;
switch (_that) {
case _AccommodationsState():
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<AccommodationsItem> items,  AccommodationsItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _AccommodationsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _AccommodationsState implements AccommodationsState {
  const _AccommodationsState({this.loading = false, this.error, final  List<AccommodationsItem> items = const <AccommodationsItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<AccommodationsItem> _items;
@override@JsonKey() List<AccommodationsItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  AccommodationsItem? detail;

/// Create a copy of AccommodationsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccommodationsStateCopyWith<_AccommodationsState> get copyWith => __$AccommodationsStateCopyWithImpl<_AccommodationsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccommodationsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'AccommodationsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$AccommodationsStateCopyWith<$Res> implements $AccommodationsStateCopyWith<$Res> {
  factory _$AccommodationsStateCopyWith(_AccommodationsState value, $Res Function(_AccommodationsState) _then) = __$AccommodationsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<AccommodationsItem> items, AccommodationsItem? detail
});




}
/// @nodoc
class __$AccommodationsStateCopyWithImpl<$Res>
    implements _$AccommodationsStateCopyWith<$Res> {
  __$AccommodationsStateCopyWithImpl(this._self, this._then);

  final _AccommodationsState _self;
  final $Res Function(_AccommodationsState) _then;

/// Create a copy of AccommodationsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_AccommodationsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AccommodationsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as AccommodationsItem?,
  ));
}


}

// dart format on
