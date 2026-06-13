/// Registration payload mapped to the Node.js `/api/auth/register` contract.
class RegistrationRequest {
  final String name;
  final String phoneNumber;
  final String gender;
  final String password;

  const RegistrationRequest({
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'password': password,
      };
}

/// Result returned after successful backend account creation.
class RegistrationResult {
  final int userId;
  final String message;

  const RegistrationResult({
    required this.userId,
    required this.message,
  });

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    return RegistrationResult(
      userId: json['userId'] as int? ?? 0,
      message: json['message'] as String? ?? 'User registered successfully',
    );
  }
}
