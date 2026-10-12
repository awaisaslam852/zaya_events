// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listings_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingsState {

 bool get loading; String? get error; List<Map<String, dynamic>> get items; Map<String, dynamic>? get detail;
/// Create a copy of ListingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingsStateCopyWith<ListingsState> get copyWith => _$ListingsStateCopyWithImpl<ListingsState>(this as ListingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.detail, detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(detail));

@override
String toString() {
  return 'ListingsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $ListingsStateCopyWith<$Res>  {
  factory $ListingsStateCopyWith(ListingsState value, $Res Function(ListingsState) _then) = _$ListingsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<Map<String, dynamic>> items, Map<String, dynamic>? detail
});




}
/// @nodoc
class _$ListingsStateCopyWithImpl<$Res>
    implements $ListingsStateCopyWith<$Res> {
  _$ListingsStateCopyWithImpl(this._self, this._then);

  final ListingsState _self;
  final $Res Function(ListingsState) _then;

/// Create a copy of ListingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingsState].
extension ListingsStatePatterns on ListingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingsState value)  $default,){
final _that = this;
switch (_that) {
case _ListingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingsState value)?  $default,){
final _that = this;
switch (_that) {
case _ListingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<Map<String, dynamic>> items,  Map<String, dynamic>? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<Map<String, dynamic>> items,  Map<String, dynamic>? detail)  $default,) {final _that = this;
switch (_that) {
case _ListingsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<Map<String, dynamic>> items,  Map<String, dynamic>? detail)?  $default,) {final _that = this;
switch (_that) {
case _ListingsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _ListingsState implements ListingsState {
  const _ListingsState({this.loading = false, this.error, final  List<Map<String, dynamic>> items = const [], final  Map<String, dynamic>? detail}): _items = items,_detail = detail;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<Map<String, dynamic>> _items;
@override@JsonKey() List<Map<String, dynamic>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, dynamic>? _detail;
@override Map<String, dynamic>? get detail {
  final value = _detail;
  if (value == null) return null;
  if (_detail is EqualUnmodifiableMapView) return _detail;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ListingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingsStateCopyWith<_ListingsState> get copyWith => __$ListingsStateCopyWithImpl<_ListingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._detail, _detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_detail));

@override
String toString() {
  return 'ListingsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$ListingsStateCopyWith<$Res> implements $ListingsStateCopyWith<$Res> {
  factory _$ListingsStateCopyWith(_ListingsState value, $Res Function(_ListingsState) _then) = __$ListingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<Map<String, dynamic>> items, Map<String, dynamic>? detail
});




}
/// @nodoc
class __$ListingsStateCopyWithImpl<$Res>
    implements _$ListingsStateCopyWith<$Res> {
  __$ListingsStateCopyWithImpl(this._self, this._then);

  final _ListingsState _self;
  final $Res Function(_ListingsState) _then;

/// Create a copy of ListingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_ListingsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,detail: freezed == detail ? _self._detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
