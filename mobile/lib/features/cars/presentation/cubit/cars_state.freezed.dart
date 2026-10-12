// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cars_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CarsState {

 bool get loading; String? get error; List<CarsItem> get items; CarsItem? get detail;
/// Create a copy of CarsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarsStateCopyWith<CarsState> get copyWith => _$CarsStateCopyWithImpl<CarsState>(this as CarsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'CarsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $CarsStateCopyWith<$Res>  {
  factory $CarsStateCopyWith(CarsState value, $Res Function(CarsState) _then) = _$CarsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<CarsItem> items, CarsItem? detail
});




}
/// @nodoc
class _$CarsStateCopyWithImpl<$Res>
    implements $CarsStateCopyWith<$Res> {
  _$CarsStateCopyWithImpl(this._self, this._then);

  final CarsState _self;
  final $Res Function(CarsState) _then;

/// Create a copy of CarsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CarsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as CarsItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [CarsState].
extension CarsStatePatterns on CarsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarsState value)  $default,){
final _that = this;
switch (_that) {
case _CarsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarsState value)?  $default,){
final _that = this;
switch (_that) {
case _CarsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<CarsItem> items,  CarsItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<CarsItem> items,  CarsItem? detail)  $default,) {final _that = this;
switch (_that) {
case _CarsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<CarsItem> items,  CarsItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _CarsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _CarsState implements CarsState {
  const _CarsState({this.loading = false, this.error, final  List<CarsItem> items = const <CarsItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<CarsItem> _items;
@override@JsonKey() List<CarsItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  CarsItem? detail;

/// Create a copy of CarsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarsStateCopyWith<_CarsState> get copyWith => __$CarsStateCopyWithImpl<_CarsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'CarsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$CarsStateCopyWith<$Res> implements $CarsStateCopyWith<$Res> {
  factory _$CarsStateCopyWith(_CarsState value, $Res Function(_CarsState) _then) = __$CarsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<CarsItem> items, CarsItem? detail
});




}
/// @nodoc
class __$CarsStateCopyWithImpl<$Res>
    implements _$CarsStateCopyWith<$Res> {
  __$CarsStateCopyWithImpl(this._self, this._then);

  final _CarsState _self;
  final $Res Function(_CarsState) _then;

/// Create a copy of CarsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_CarsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CarsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as CarsItem?,
  ));
}


}

// dart format on
