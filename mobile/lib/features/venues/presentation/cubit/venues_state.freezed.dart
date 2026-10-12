// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venues_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VenuesState {

 bool get loading; String? get error; List<VenuesItem> get items; VenuesItem? get detail;
/// Create a copy of VenuesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenuesStateCopyWith<VenuesState> get copyWith => _$VenuesStateCopyWithImpl<VenuesState>(this as VenuesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenuesState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'VenuesState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $VenuesStateCopyWith<$Res>  {
  factory $VenuesStateCopyWith(VenuesState value, $Res Function(VenuesState) _then) = _$VenuesStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<VenuesItem> items, VenuesItem? detail
});




}
/// @nodoc
class _$VenuesStateCopyWithImpl<$Res>
    implements $VenuesStateCopyWith<$Res> {
  _$VenuesStateCopyWithImpl(this._self, this._then);

  final VenuesState _self;
  final $Res Function(VenuesState) _then;

/// Create a copy of VenuesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VenuesItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as VenuesItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenuesState].
extension VenuesStatePatterns on VenuesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenuesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenuesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenuesState value)  $default,){
final _that = this;
switch (_that) {
case _VenuesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenuesState value)?  $default,){
final _that = this;
switch (_that) {
case _VenuesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<VenuesItem> items,  VenuesItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenuesState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<VenuesItem> items,  VenuesItem? detail)  $default,) {final _that = this;
switch (_that) {
case _VenuesState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<VenuesItem> items,  VenuesItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _VenuesState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _VenuesState implements VenuesState {
  const _VenuesState({this.loading = false, this.error, final  List<VenuesItem> items = const <VenuesItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<VenuesItem> _items;
@override@JsonKey() List<VenuesItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  VenuesItem? detail;

/// Create a copy of VenuesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenuesStateCopyWith<_VenuesState> get copyWith => __$VenuesStateCopyWithImpl<_VenuesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenuesState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'VenuesState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$VenuesStateCopyWith<$Res> implements $VenuesStateCopyWith<$Res> {
  factory _$VenuesStateCopyWith(_VenuesState value, $Res Function(_VenuesState) _then) = __$VenuesStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<VenuesItem> items, VenuesItem? detail
});




}
/// @nodoc
class __$VenuesStateCopyWithImpl<$Res>
    implements _$VenuesStateCopyWith<$Res> {
  __$VenuesStateCopyWithImpl(this._self, this._then);

  final _VenuesState _self;
  final $Res Function(_VenuesState) _then;

/// Create a copy of VenuesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_VenuesState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VenuesItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as VenuesItem?,
  ));
}


}

// dart format on
