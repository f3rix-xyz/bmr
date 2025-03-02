
import 'package:dtx/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verification_state.dart';
import '../repositories/verification_repository.dart';

final verificationProvider = StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier(ref.watch(verificationRepositoryProvider));
});

class VerificationNotifier extends StateNotifier<VerificationState> {
  final VerificationRepository _repository;

  VerificationNotifier(this._repository) : super(const VerificationState.initial());

  Future<void> fetchVerifications() async {
    try {
      state = const VerificationState.loading();
      final requests = await _repository.getPendingVerifications();
      state = VerificationState.loaded(requests);
    } catch (e) {
      state = VerificationState.error(e.toString());
    }
  }

  Future<bool> updateVerificationStatus(int userId, bool approve) async {
    try {
      final success = await _repository.updateVerificationStatus(userId, approve);
      
      if (success) {
        // If update was successful, refresh the list
        fetchVerifications();
      }
      
      return success;
    } catch (e) {
      state = VerificationState.error(e.toString());
      return false;
    }
  }
}
