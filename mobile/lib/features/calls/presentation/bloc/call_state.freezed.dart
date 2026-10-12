// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallState {

 CallEntity? get incoming; CallEntity? get outgoing; CallEntity? get active; CallToken? get token; List<CallEntity> get history; bool get loading; String? get error;
/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallStateCopyWith<CallState> get copyWith => _$CallStateCopyWithImpl<CallState>(this as CallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState&&(identical(other.incoming, incoming) || other.incoming == incoming)&&(identical(other.outgoing, outgoing) || other.outgoing == outgoing)&&(identical(other.active, active) || other.active == active)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,incoming,outgoing,active,token,const DeepCollectionEquality().hash(history),loading,error);

@override
String toString() {
  return 'CallState(incoming: $incoming, outgoing: $outgoing, active: $active, token: $token, history: $history, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class $CallStateCopyWith<$Res>  {
  factory $CallStateCopyWith(CallState value, $Res Function(CallState) _then) = _$CallStateCopyWithImpl;
@useResult
$Res call({
 CallEntity? incoming, CallEntity? outgoing, CallEntity? active, CallToken? token, List<CallEntity> history, bool loading, String? error
});




}
/// @nodoc
class _$CallStateCopyWithImpl<$Res>
    implements $CallStateCopyWith<$Res> {
  _$CallStateCopyWithImpl(this._self, this._then);

  final CallState _self;
  final $Res Function(CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? incoming = freezed,Object? outgoing = freezed,Object? active = freezed,Object? token = freezed,Object? history = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
incoming: freezed == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as CallEntity?,outgoing: freezed == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as CallEntity?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as CallEntity?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as CallToken?,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<CallEntity>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallState].
extension CallStatePatterns on CallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallState value)  $default,){
final _that = this;
switch (_that) {
case _CallState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallState value)?  $default,){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CallEntity? incoming,  CallEntity? outgoing,  CallEntity? active,  CallToken? token,  List<CallEntity> history,  bool loading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.incoming,_that.outgoing,_that.active,_that.token,_that.history,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CallEntity? incoming,  CallEntity? outgoing,  CallEntity? active,  CallToken? token,  List<CallEntity> history,  bool loading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CallState():
return $default(_that.incoming,_that.outgoing,_that.active,_that.token,_that.history,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CallEntity? incoming,  CallEntity? outgoing,  CallEntity? active,  CallToken? token,  List<CallEntity> history,  bool loading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.incoming,_that.outgoing,_that.active,_that.token,_that.history,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CallState implements CallState {
  const _CallState({this.incoming, this.outgoing, this.active, this.token, final  List<CallEntity> history = const [], this.loading = false, this.error}): _history = history;
  

@override final  CallEntity? incoming;
@override final  CallEntity? outgoing;
@override final  CallEntity? active;
@override final  CallToken? token;
 final  List<CallEntity> _history;
@override@JsonKey() List<CallEntity> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  bool loading;
@override final  String? error;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallStateCopyWith<_CallState> get copyWith => __$CallStateCopyWithImpl<_CallState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallState&&(identical(other.incoming, incoming) || other.incoming == incoming)&&(identical(other.outgoing, outgoing) || other.outgoing == outgoing)&&(identical(other.active, active) || other.active == active)&&(identical(other.token, token) || other.token == token)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,incoming,outgoing,active,token,const DeepCollectionEquality().hash(_history),loading,error);

@override
String toString() {
  return 'CallState(incoming: $incoming, outgoing: $outgoing, active: $active, token: $token, history: $history, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CallStateCopyWith<$Res> implements $CallStateCopyWith<$Res> {
  factory _$CallStateCopyWith(_CallState value, $Res Function(_CallState) _then) = __$CallStateCopyWithImpl;
@override @useResult
$Res call({
 CallEntity? incoming, CallEntity? outgoing, CallEntity? active, CallToken? token, List<CallEntity> history, bool loading, String? error
});




}
/// @nodoc
class __$CallStateCopyWithImpl<$Res>
    implements _$CallStateCopyWith<$Res> {
  __$CallStateCopyWithImpl(this._self, this._then);

  final _CallState _self;
  final $Res Function(_CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? incoming = freezed,Object? outgoing = freezed,Object? active = freezed,Object? token = freezed,Object? history = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_CallState(
incoming: freezed == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as CallEntity?,outgoing: freezed == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as CallEntity?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as CallEntity?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as CallToken?,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<CallEntity>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
