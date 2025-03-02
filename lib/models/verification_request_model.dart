
class VerificationRequest {
  final int userId;
  final String name;
  final String profileImageUrl;
  final String verificationUrl;

  VerificationRequest({
    required this.userId,
    required this.name,
    required this.profileImageUrl,
    required this.verificationUrl,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      userId: json['user_id'],
      name: json['name'] ?? 'Unknown User',
      profileImageUrl: json['profile_image_url'] ?? '',
      verificationUrl: json['verification_url'] ?? '',
    );
  }
}
