// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent()';
}


}

/// @nodoc
class $CallEventCopyWith<$Res>  {
$CallEventCopyWith(CallEvent _, $Res Function(CallEvent) __);
}


/// Adds pattern-matching-related methods to [CallEvent].
extension CallEventPatterns on CallEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _IncomingFromPush value)?  incomingFromPush,TResult Function( _Outgoing value)?  outgoing,TResult Function( _Accept value)?  accept,TResult Function( _Reject value)?  reject,TResult Function( _End value)?  end,TResult Function( _LoadHistory value)?  loadHistory,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _IncomingFromPush() when incomingFromPush != null:
return incomingFromPush(_that);case _Outgoing() when outgoing != null:
return outgoing(_that);case _Accept() when accept != null:
return accept(_that);case _Reject() when reject != null:
return reject(_that);case _End() when end != null:
return end(_that);case _LoadHistory() when loadHistory != null:
return loadHistory(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _IncomingFromPush value)  incomingFromPush,required TResult Function( _Outgoing value)  outgoing,required TResult Function( _Accept value)  accept,required TResult Function( _Reject value)  reject,required TResult Function( _End value)  end,required TResult Function( _LoadHistory value)  loadHistory,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _IncomingFromPush():
return incomingFromPush(_that);case _Outgoing():
return outgoing(_that);case _Accept():
return accept(_that);case _Reject():
return reject(_that);case _End():
return end(_that);case _LoadHistory():
return loadHistory(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _IncomingFromPush value)?  incomingFromPush,TResult? Function( _Outgoing value)?  outgoing,TResult? Function( _Accept value)?  accept,TResult? Function( _Reject value)?  reject,TResult? Function( _End value)?  end,TResult? Function( _LoadHistory value)?  loadHistory,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _IncomingFromPush() when incomingFromPush != null:
return incomingFromPush(_that);case _Outgoing() when outgoing != null:
return outgoing(_that);case _Accept() when accept != null:
return accept(_that);case _Reject() when reject != null:
return reject(_that);case _End() when end != null:
return end(_that);case _LoadHistory() when loadHistory != null:
return loadHistory(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( Map<String, dynamic> payload)?  incomingFromPush,TResult Function( String calleeId,  String? bookingId)?  outgoing,TResult Function( String id)?  accept,TResult Function( String id)?  reject,TResult Function( String id)?  end,TResult Function()?  loadHistory,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _IncomingFromPush() when incomingFromPush != null:
return incomingFromPush(_that.payload);case _Outgoing() when outgoing != null:
return outgoing(_that.calleeId,_that.bookingId);case _Accept() when accept != null:
return accept(_that.id);case _Reject() when reject != null:
return reject(_that.id);case _End() when end != null:
return end(_that.id);case _LoadHistory() when loadHistory != null:
return loadHistory();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( Map<String, dynamic> payload)  incomingFromPush,required TResult Function( String calleeId,  String? bookingId)  outgoing,required TResult Function( String id)  accept,required TResult Function( String id)  reject,required TResult Function( String id)  end,required TResult Function()  loadHistory,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _IncomingFromPush():
return incomingFromPush(_that.payload);case _Outgoing():
return outgoing(_that.calleeId,_that.bookingId);case _Accept():
return accept(_that.id);case _Reject():
return reject(_that.id);case _End():
return end(_that.id);case _LoadHistory():
return loadHistory();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( Map<String, dynamic> payload)?  incomingFromPush,TResult? Function( String calleeId,  String? bookingId)?  outgoing,TResult? Function( String id)?  accept,TResult? Function( String id)?  reject,TResult? Function( String id)?  end,TResult? Function()?  loadHistory,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _IncomingFromPush() when incomingFromPush != null:
return incomingFromPush(_that.payload);case _Outgoing() when outgoing != null:
return outgoing(_that.calleeId,_that.bookingId);case _Accept() when accept != null:
return accept(_that.id);case _Reject() when reject != null:
return reject(_that.id);case _End() when end != null:
return end(_that.id);case _LoadHistory() when loadHistory != null:
return loadHistory();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements CallEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.started()';
}


}




/// @nodoc


class _IncomingFromPush implements CallEvent {
  const _IncomingFromPush(final  Map<String, dynamic> payload): _payload = payload;
  

 final  Map<String, dynamic> _payload;
 Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomingFromPushCopyWith<_IncomingFromPush> get copyWith => __$IncomingFromPushCopyWithImpl<_IncomingFromPush>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomingFromPush&&const DeepCollectionEquality().equals(other._payload, _payload));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'CallEvent.incomingFromPush(payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$IncomingFromPushCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$IncomingFromPushCopyWith(_IncomingFromPush value, $Res Function(_IncomingFromPush) _then) = __$IncomingFromPushCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> payload
});




}
/// @nodoc
class __$IncomingFromPushCopyWithImpl<$Res>
    implements _$IncomingFromPushCopyWith<$Res> {
  __$IncomingFromPushCopyWithImpl(this._self, this._then);

  final _IncomingFromPush _self;
  final $Res Function(_IncomingFromPush) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payload = null,}) {
  return _then(_IncomingFromPush(
null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _Outgoing implements CallEvent {
  const _Outgoing({required this.calleeId, this.bookingId});
  

 final  String calleeId;
 final  String? bookingId;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutgoingCopyWith<_Outgoing> get copyWith => __$OutgoingCopyWithImpl<_Outgoing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Outgoing&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId));
}


@override
int get hashCode => Object.hash(runtimeType,calleeId,bookingId);

@override
String toString() {
  return 'CallEvent.outgoing(calleeId: $calleeId, bookingId: $bookingId)';
}


}

/// @nodoc
abstract mixin class _$OutgoingCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$OutgoingCopyWith(_Outgoing value, $Res Function(_Outgoing) _then) = __$OutgoingCopyWithImpl;
@useResult
$Res call({
 String calleeId, String? bookingId
});




}
/// @nodoc
class __$OutgoingCopyWithImpl<$Res>
    implements _$OutgoingCopyWith<$Res> {
  __$OutgoingCopyWithImpl(this._self, this._then);

  final _Outgoing _self;
  final $Res Function(_Outgoing) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? calleeId = null,Object? bookingId = freezed,}) {
  return _then(_Outgoing(
calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Accept implements CallEvent {
  const _Accept(this.id);
  

 final  String id;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptCopyWith<_Accept> get copyWith => __$AcceptCopyWithImpl<_Accept>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Accept&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'CallEvent.accept(id: $id)';
}


}

/// @nodoc
abstract mixin class _$AcceptCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$AcceptCopyWith(_Accept value, $Res Function(_Accept) _then) = __$AcceptCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$AcceptCopyWithImpl<$Res>
    implements _$AcceptCopyWith<$Res> {
  __$AcceptCopyWithImpl(this._self, this._then);

  final _Accept _self;
  final $Res Function(_Accept) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_Accept(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Reject implements CallEvent {
  const _Reject(this.id);
  

 final  String id;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RejectCopyWith<_Reject> get copyWith => __$RejectCopyWithImpl<_Reject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reject&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'CallEvent.reject(id: $id)';
}


}

/// @nodoc
abstract mixin class _$RejectCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$RejectCopyWith(_Reject value, $Res Function(_Reject) _then) = __$RejectCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$RejectCopyWithImpl<$Res>
    implements _$RejectCopyWith<$Res> {
  __$RejectCopyWithImpl(this._self, this._then);

  final _Reject _self;
  final $Res Function(_Reject) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_Reject(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _End implements CallEvent {
  const _End(this.id);
  

 final  String id;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EndCopyWith<_End> get copyWith => __$EndCopyWithImpl<_End>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _End&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'CallEvent.end(id: $id)';
}


}

/// @nodoc
abstract mixin class _$EndCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory _$EndCopyWith(_End value, $Res Function(_End) _then) = __$EndCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$EndCopyWithImpl<$Res>
    implements _$EndCopyWith<$Res> {
  __$EndCopyWithImpl(this._self, this._then);

  final _End _self;
  final $Res Function(_End) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_End(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadHistory implements CallEvent {
  const _LoadHistory();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadHistory);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.loadHistory()';
}


}




// dart format on
