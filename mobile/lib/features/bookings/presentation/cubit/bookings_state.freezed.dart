// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingsState {

 bool get loading; String? get error; List<BookingsItem> get items; BookingsItem? get detail;
/// Create a copy of BookingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingsStateCopyWith<BookingsState> get copyWith => _$BookingsStateCopyWithImpl<BookingsState>(this as BookingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(items),detail);

@override
String toString() {
  return 'BookingsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $BookingsStateCopyWith<$Res>  {
  factory $BookingsStateCopyWith(BookingsState value, $Res Function(BookingsState) _then) = _$BookingsStateCopyWithImpl;
@useResult
$Res call({
 bool loading, String? error, List<BookingsItem> items, BookingsItem? detail
});




}
/// @nodoc
class _$BookingsStateCopyWithImpl<$Res>
    implements $BookingsStateCopyWith<$Res> {
  _$BookingsStateCopyWithImpl(this._self, this._then);

  final BookingsState _self;
  final $Res Function(BookingsState) _then;

/// Create a copy of BookingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BookingsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as BookingsItem?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingsState].
extension BookingsStatePatterns on BookingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingsState value)  $default,){
final _that = this;
switch (_that) {
case _BookingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingsState value)?  $default,){
final _that = this;
switch (_that) {
case _BookingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<BookingsItem> items,  BookingsItem? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  String? error,  List<BookingsItem> items,  BookingsItem? detail)  $default,) {final _that = this;
switch (_that) {
case _BookingsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  String? error,  List<BookingsItem> items,  BookingsItem? detail)?  $default,) {final _that = this;
switch (_that) {
case _BookingsState() when $default != null:
return $default(_that.loading,_that.error,_that.items,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _BookingsState implements BookingsState {
  const _BookingsState({this.loading = false, this.error, final  List<BookingsItem> items = const <BookingsItem>[], this.detail}): _items = items;
  

@override@JsonKey() final  bool loading;
@override final  String? error;
 final  List<BookingsItem> _items;
@override@JsonKey() List<BookingsItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  BookingsItem? detail;

/// Create a copy of BookingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingsStateCopyWith<_BookingsState> get copyWith => __$BookingsStateCopyWithImpl<_BookingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingsState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,loading,error,const DeepCollectionEquality().hash(_items),detail);

@override
String toString() {
  return 'BookingsState(loading: $loading, error: $error, items: $items, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$BookingsStateCopyWith<$Res> implements $BookingsStateCopyWith<$Res> {
  factory _$BookingsStateCopyWith(_BookingsState value, $Res Function(_BookingsState) _then) = __$BookingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, String? error, List<BookingsItem> items, BookingsItem? detail
});




}
/// @nodoc
class __$BookingsStateCopyWithImpl<$Res>
    implements _$BookingsStateCopyWith<$Res> {
  __$BookingsStateCopyWithImpl(this._self, this._then);

  final _BookingsState _self;
  final $Res Function(_BookingsState) _then;

/// Create a copy of BookingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? error = freezed,Object? items = null,Object? detail = freezed,}) {
  return _then(_BookingsState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BookingsItem>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as BookingsItem?,
  ));
}


}

// dart format on
