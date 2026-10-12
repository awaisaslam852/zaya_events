// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Login value)?  login,TResult Function( _Register value)?  register,TResult Function( _Logout value)?  logout,TResult Function( _UserUpdated value)?  userUpdated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Login() when login != null:
return login(_that);case _Register() when register != null:
return register(_that);case _Logout() when logout != null:
return logout(_that);case _UserUpdated() when userUpdated != null:
return userUpdated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Login value)  login,required TResult Function( _Register value)  register,required TResult Function( _Logout value)  logout,required TResult Function( _UserUpdated value)  userUpdated,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Login():
return login(_that);case _Register():
return register(_that);case _Logout():
return logout(_that);case _UserUpdated():
return userUpdated(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Login value)?  login,TResult? Function( _Register value)?  register,TResult? Function( _Logout value)?  logout,TResult? Function( _UserUpdated value)?  userUpdated,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Login() when login != null:
return login(_that);case _Register() when register != null:
return register(_that);case _Logout() when logout != null:
return logout(_that);case _UserUpdated() when userUpdated != null:
return userUpdated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String email,  String password)?  login,TResult Function( String email,  String password,  String firstName,  String lastName,  String role,  String country,  String? phone,  String? locale,  String? businessNameEn,  String? businessNameAr,  String? city,  String? legalName,  String? taxId,  String? website,  String? avatarPath,  String? avatarName)?  register,TResult Function()?  logout,TResult Function()?  userUpdated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Login() when login != null:
return login(_that.email,_that.password);case _Register() when register != null:
return register(_that.email,_that.password,_that.firstName,_that.lastName,_that.role,_that.country,_that.phone,_that.locale,_that.businessNameEn,_that.businessNameAr,_that.city,_that.legalName,_that.taxId,_that.website,_that.avatarPath,_that.avatarName);case _Logout() when logout != null:
return logout();case _UserUpdated() when userUpdated != null:
return userUpdated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String email,  String password)  login,required TResult Function( String email,  String password,  String firstName,  String lastName,  String role,  String country,  String? phone,  String? locale,  String? businessNameEn,  String? businessNameAr,  String? city,  String? legalName,  String? taxId,  String? website,  String? avatarPath,  String? avatarName)  register,required TResult Function()  logout,required TResult Function()  userUpdated,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Login():
return login(_that.email,_that.password);case _Register():
return register(_that.email,_that.password,_that.firstName,_that.lastName,_that.role,_that.country,_that.phone,_that.locale,_that.businessNameEn,_that.businessNameAr,_that.city,_that.legalName,_that.taxId,_that.website,_that.avatarPath,_that.avatarName);case _Logout():
return logout();case _UserUpdated():
return userUpdated();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String email,  String password)?  login,TResult? Function( String email,  String password,  String firstName,  String lastName,  String role,  String country,  String? phone,  String? locale,  String? businessNameEn,  String? businessNameAr,  String? city,  String? legalName,  String? taxId,  String? website,  String? avatarPath,  String? avatarName)?  register,TResult? Function()?  logout,TResult? Function()?  userUpdated,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Login() when login != null:
return login(_that.email,_that.password);case _Register() when register != null:
return register(_that.email,_that.password,_that.firstName,_that.lastName,_that.role,_that.country,_that.phone,_that.locale,_that.businessNameEn,_that.businessNameAr,_that.city,_that.legalName,_that.taxId,_that.website,_that.avatarPath,_that.avatarName);case _Logout() when logout != null:
return logout();case _UserUpdated() when userUpdated != null:
return userUpdated();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements AuthEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.started()';
}


}




/// @nodoc


class _Login implements AuthEvent {
  const _Login({required this.email, required this.password});
  

 final  String email;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginCopyWith<_Login> get copyWith => __$LoginCopyWithImpl<_Login>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Login&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthEvent.login(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory _$LoginCopyWith(_Login value, $Res Function(_Login) _then) = __$LoginCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$LoginCopyWithImpl<$Res>
    implements _$LoginCopyWith<$Res> {
  __$LoginCopyWithImpl(this._self, this._then);

  final _Login _self;
  final $Res Function(_Login) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_Login(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Register implements AuthEvent {
  const _Register({required this.email, required this.password, required this.firstName, required this.lastName, required this.role, required this.country, this.phone, this.locale, this.businessNameEn, this.businessNameAr, this.city, this.legalName, this.taxId, this.website, this.avatarPath, this.avatarName});
  

 final  String email;
 final  String password;
 final  String firstName;
 final  String lastName;
 final  String role;
 final  String country;
 final  String? phone;
 final  String? locale;
 final  String? businessNameEn;
 final  String? businessNameAr;
 final  String? city;
 final  String? legalName;
 final  String? taxId;
 final  String? website;
 final  String? avatarPath;
 final  String? avatarName;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterCopyWith<_Register> get copyWith => __$RegisterCopyWithImpl<_Register>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Register&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.businessNameEn, businessNameEn) || other.businessNameEn == businessNameEn)&&(identical(other.businessNameAr, businessNameAr) || other.businessNameAr == businessNameAr)&&(identical(other.city, city) || other.city == city)&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.website, website) || other.website == website)&&(identical(other.avatarPath, avatarPath) || other.avatarPath == avatarPath)&&(identical(other.avatarName, avatarName) || other.avatarName == avatarName));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,firstName,lastName,role,country,phone,locale,businessNameEn,businessNameAr,city,legalName,taxId,website,avatarPath,avatarName);

@override
String toString() {
  return 'AuthEvent.register(email: $email, password: $password, firstName: $firstName, lastName: $lastName, role: $role, country: $country, phone: $phone, locale: $locale, businessNameEn: $businessNameEn, businessNameAr: $businessNameAr, city: $city, legalName: $legalName, taxId: $taxId, website: $website, avatarPath: $avatarPath, avatarName: $avatarName)';
}


}

/// @nodoc
abstract mixin class _$RegisterCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory _$RegisterCopyWith(_Register value, $Res Function(_Register) _then) = __$RegisterCopyWithImpl;
@useResult
$Res call({
 String email, String password, String firstName, String lastName, String role, String country, String? phone, String? locale, String? businessNameEn, String? businessNameAr, String? city, String? legalName, String? taxId, String? website, String? avatarPath, String? avatarName
});




}
/// @nodoc
class __$RegisterCopyWithImpl<$Res>
    implements _$RegisterCopyWith<$Res> {
  __$RegisterCopyWithImpl(this._self, this._then);

  final _Register _self;
  final $Res Function(_Register) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? role = null,Object? country = null,Object? phone = freezed,Object? locale = freezed,Object? businessNameEn = freezed,Object? businessNameAr = freezed,Object? city = freezed,Object? legalName = freezed,Object? taxId = freezed,Object? website = freezed,Object? avatarPath = freezed,Object? avatarName = freezed,}) {
  return _then(_Register(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,businessNameEn: freezed == businessNameEn ? _self.businessNameEn : businessNameEn // ignore: cast_nullable_to_non_nullable
as String?,businessNameAr: freezed == businessNameAr ? _self.businessNameAr : businessNameAr // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,legalName: freezed == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,avatarPath: freezed == avatarPath ? _self.avatarPath : avatarPath // ignore: cast_nullable_to_non_nullable
as String?,avatarName: freezed == avatarName ? _self.avatarName : avatarName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Logout implements AuthEvent {
  const _Logout();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Logout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.logout()';
}


}




/// @nodoc


class _UserUpdated implements AuthEvent {
  const _UserUpdated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserUpdated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.userUpdated()';
}


}




// dart format on
