// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendors_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VendorsState {

 bool get loading; String? get error; List<VendorsItem> get items; VendorsItem? get detail;
/// Create a copy of VendorsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorsStateCopyWith<VendorsState> get copyWith => _$VendorsStateCopyWithImpl<VendorsState>(this as VendorsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'VendorsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $VendorsStateCopyWith<$Res>  {
  factory $VendorsStateCopyWith(VendorsState value, $Res Function(VendorsState) _then) = _$VendorsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<VendorsItem> items, VendorsItem? detail
});




}
/// @nodoc
class _$VendorsStateCopyWithImpl<$Res>
    implements $VendorsStateCopyWith<$Res> {
  _$VendorsStateCopyWithImpl(this._self, this._then);

  final VendorsState _self;
  final $Res Function(VendorsState) _then;

/// Create a copy of VendorsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VendorsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as VendorsItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorsState].
extension VendorsStatePatterns on VendorsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorsState value)  $default,){
final _that = this;
switch (_that) {
case _VendorsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorsState value)?  $default,){
final _that = this;
switch (_that) {
case _VendorsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<VendorsItem> items,  VendorsItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<VendorsItem> items,  VendorsItem? detail)  $default,) {final _that = this;
switch (_that) {
case _VendorsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<VendorsItem> items,  VendorsItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _VendorsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _VendorsState implements VendorsState {
  const _VendorsState({this.loading = false, this.error, final  List<VendorsItem> items = const <VendorsItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<VendorsItem> _items;
@override@JsonKey() List<VendorsItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  VendorsItem? detail;

/// Create a copy of VendorsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorsStateCopyWith<_VendorsState> get copyWith => __$VendorsStateCopyWithImpl<_VendorsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'VendorsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$VendorsStateCopyWith<$Res> implements $VendorsStateCopyWith<$Res> {
  factory _$VendorsStateCopyWith(_VendorsState value, $Res Function(_VendorsState) _then) = __$VendorsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<VendorsItem> items, VendorsItem? detail
});




}
/// @nodoc
class __$VendorsStateCopyWithImpl<$Res>
    implements _$VendorsStateCopyWith<$Res> {
  __$VendorsStateCopyWithImpl(this._self, this._then);

  final _VendorsState _self;
  final $Res Function(_VendorsState) _then;

/// Create a copy of VendorsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_VendorsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VendorsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as VendorsItem?,
  ));
}


}

// dart format on
