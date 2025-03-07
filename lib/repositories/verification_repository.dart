import 'dart:convert';
import '../models/verification_request_model.dart';
import '../services/api_service.dart';
import '../utils/token_storage.dart';

class VerificationRepository {
  final ApiService _apiService;

  VerificationRepository(this._apiService);

  Future<List<VerificationRequest>> getPendingVerifications() async {
    try {
      // Get the auth token
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw ApiException("Authentication token is missing");
      }

      // Add the token to headers
      final headers = _apiService.addAuthToken({}, token);

      // Make the request with auth headers
      final response = await _apiService.get(
        '/api/admin/verifications',
        headers: headers,
      );

      if (response['success'] == true) {
        // Check if verification_requests exists and is not null
        if (response['verification_requests'] != null) {
          final requests = (response['verification_requests'] as List)
              .map((item) => VerificationRequest.fromJson(item))
              .toList();
          return requests;
        } else {
          // Return empty list instead of throwing an exception
          return [];
        }
      } else {
        // Only throw exception for actual API failures
        throw ApiException(
            response['message'] ?? 'Failed to get verification requests');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error fetching verifications: ${e.toString()}');
    }
  }

  Future<bool> updateVerificationStatus(int userId, bool approve) async {
    try {
      // Get the auth token
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw ApiException("Authentication token is missing");
      }

      // Add the token to headers
      final headers = _apiService.addAuthToken({}, token);

      // Make the request with auth headers
      final response = await _apiService.post(
        '/api/admin/verify',
        headers: headers,
        body: {
          'user_id': userId,
          'approve': approve,
        },
      );

      return response['success'] == true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error updating verification status: ${e.toString()}');
    }
  }
}
