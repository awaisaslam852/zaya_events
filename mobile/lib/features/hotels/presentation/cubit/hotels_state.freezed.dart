// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hotels_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotelsState {

 bool get loading; String? get error; List<HotelsItem> get items; HotelsItem? get detail;
/// Create a copy of HotelsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotelsStateCopyWith<HotelsState> get copyWith => _$HotelsStateCopyWithImpl<HotelsState>(this as HotelsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotelsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'HotelsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $HotelsStateCopyWith<$Res>  {
  factory $HotelsStateCopyWith(HotelsState value, $Res Function(HotelsState) _then) = _$HotelsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<HotelsItem> items, HotelsItem? detail
});




}
/// @nodoc
class _$HotelsStateCopyWithImpl<$Res>
    implements $HotelsStateCopyWith<$Res> {
  _$HotelsStateCopyWithImpl(this._self, this._then);

  final HotelsState _self;
  final $Res Function(HotelsState) _then;

/// Create a copy of HotelsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<HotelsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as HotelsItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [HotelsState].
extension HotelsStatePatterns on HotelsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotelsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotelsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotelsState value)  $default,){
final _that = this;
switch (_that) {
case _HotelsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotelsState value)?  $default,){
final _that = this;
switch (_that) {
case _HotelsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<HotelsItem> items,  HotelsItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotelsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<HotelsItem> items,  HotelsItem? detail)  $default,) {final _that = this;
switch (_that) {
case _HotelsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<HotelsItem> items,  HotelsItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _HotelsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _HotelsState implements HotelsState {
  const _HotelsState({this.loading = false, this.error, final  List<HotelsItem> items = const <HotelsItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<HotelsItem> _items;
@override@JsonKey() List<HotelsItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  HotelsItem? detail;

/// Create a copy of HotelsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotelsStateCopyWith<_HotelsState> get copyWith => __$HotelsStateCopyWithImpl<_HotelsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotelsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'HotelsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$HotelsStateCopyWith<$Res> implements $HotelsStateCopyWith<$Res> {
  factory _$HotelsStateCopyWith(_HotelsState value, $Res Function(_HotelsState) _then) = __$HotelsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<HotelsItem> items, HotelsItem? detail
});




}
/// @nodoc
class __$HotelsStateCopyWithImpl<$Res>
    implements _$HotelsStateCopyWith<$Res> {
  __$HotelsStateCopyWithImpl(this._self, this._then);

  final _HotelsState _self;
  final $Res Function(_HotelsState) _then;

/// Create a copy of HotelsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_HotelsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<HotelsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as HotelsItem?,
  ));
}


}

// dart format on
