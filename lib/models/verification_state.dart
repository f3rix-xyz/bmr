
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/verification_request_model.dart';

part 'verification_state.freezed.dart';

@freezed
class VerificationState with _$VerificationState {
  const factory VerificationState.initial() = _Initial;
  const factory VerificationState.loading() = _Loading;
  const factory VerificationState.loaded(List<VerificationRequest> requests) = _Loaded;
  const factory VerificationState.error(String message) = _Error;
}
