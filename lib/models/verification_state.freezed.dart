// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VerificationState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationState()';
  }
}

/// @nodoc
class $VerificationStateCopyWith<$Res> {
  $VerificationStateCopyWith(
      VerificationState _, $Res Function(VerificationState) __);
}

/// @nodoc

class _Initial implements VerificationState {
  const _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationState.initial()';
  }
}

/// @nodoc

class _Loading implements VerificationState {
  const _Loading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Loading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationState.loading()';
  }
}

/// @nodoc

class _Loaded implements VerificationState {
  const _Loaded(final List<VerificationRequest> requests)
      : _requests = requests;

  final List<VerificationRequest> _requests;
  List<VerificationRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  /// Create a copy of VerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadedCopyWith<_Loaded> get copyWith =>
      __$LoadedCopyWithImpl<_Loaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Loaded &&
            const DeepCollectionEquality().equals(other._requests, _requests));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_requests));

  @override
  String toString() {
    return 'VerificationState.loaded(requests: $requests)';
  }
}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res>
    implements $VerificationStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) =
      __$LoadedCopyWithImpl;
  @useResult
  $Res call({List<VerificationRequest> requests});
}

/// @nodoc
class __$LoadedCopyWithImpl<$Res> implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

  /// Create a copy of VerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requests = null,
  }) {
    return _then(_Loaded(
      null == requests
          ? _self._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<VerificationRequest>,
    ));
  }
}

/// @nodoc

class _Error implements VerificationState {
  const _Error(this.message);

  final String message;

  /// Create a copy of VerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ErrorCopyWith<_Error> get copyWith =>
      __$ErrorCopyWithImpl<_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'VerificationState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $VerificationStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) =
      __$ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$ErrorCopyWithImpl<$Res> implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

  /// Create a copy of VerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_Error(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
