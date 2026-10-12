// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'honeymoon_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HoneymoonState {

 bool get loading; String? get error; List<HoneymoonItem> get items; HoneymoonItem? get detail;
/// Create a copy of HoneymoonState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoneymoonStateCopyWith<HoneymoonState> get copyWith => _$HoneymoonStateCopyWithImpl<HoneymoonState>(this as HoneymoonState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoneymoonState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'HoneymoonState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $HoneymoonStateCopyWith<$Res>  {
  factory $HoneymoonStateCopyWith(HoneymoonState value, $Res Function(HoneymoonState) _then) = _$HoneymoonStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<HoneymoonItem> items, HoneymoonItem? detail
});




}
/// @nodoc
class _$HoneymoonStateCopyWithImpl<$Res>
    implements $HoneymoonStateCopyWith<$Res> {
  _$HoneymoonStateCopyWithImpl(this._self, this._then);

  final HoneymoonState _self;
  final $Res Function(HoneymoonState) _then;

/// Create a copy of HoneymoonState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<HoneymoonItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as HoneymoonItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [HoneymoonState].
extension HoneymoonStatePatterns on HoneymoonState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoneymoonState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoneymoonState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoneymoonState value)  $default,){
final _that = this;
switch (_that) {
case _HoneymoonState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoneymoonState value)?  $default,){
final _that = this;
switch (_that) {
case _HoneymoonState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<HoneymoonItem> items,  HoneymoonItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoneymoonState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<HoneymoonItem> items,  HoneymoonItem? detail)  $default,) {final _that = this;
switch (_that) {
case _HoneymoonState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<HoneymoonItem> items,  HoneymoonItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _HoneymoonState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _HoneymoonState implements HoneymoonState {
  const _HoneymoonState({this.loading = false, this.error, final  List<HoneymoonItem> items = const <HoneymoonItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<HoneymoonItem> _items;
@override@JsonKey() List<HoneymoonItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  HoneymoonItem? detail;

/// Create a copy of HoneymoonState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoneymoonStateCopyWith<_HoneymoonState> get copyWith => __$HoneymoonStateCopyWithImpl<_HoneymoonState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoneymoonState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'HoneymoonState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$HoneymoonStateCopyWith<$Res> implements $HoneymoonStateCopyWith<$Res> {
  factory _$HoneymoonStateCopyWith(_HoneymoonState value, $Res Function(_HoneymoonState) _then) = __$HoneymoonStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<HoneymoonItem> items, HoneymoonItem? detail
});




}
/// @nodoc
class __$HoneymoonStateCopyWithImpl<$Res>
    implements _$HoneymoonStateCopyWith<$Res> {
  __$HoneymoonStateCopyWithImpl(this._self, this._then);

  final _HoneymoonState _self;
  final $Res Function(_HoneymoonState) _then;

/// Create a copy of HoneymoonState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_HoneymoonState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<HoneymoonItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as HoneymoonItem?,
  ));
}


}

// dart format on
