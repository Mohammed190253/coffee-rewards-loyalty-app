import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/network_config.dart';
import '../../data/models/registration_request.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final http.Client _client;
  final String _baseUrl;

  AuthRepositoryImpl({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? NetworkConfig.apiBaseUrl;

  @override
  Future<RegistrationResult> registerCustomer(RegistrationRequest request) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');
    final response = await _client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'bypass-tunnel-reminder': 'true',
          },
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RegistrationResult.fromJson(data);
    }

    if (response.statusCode == 409) {
      throw Exception('This phone number is already registered.');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Registration failed. Please try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Invalid server response');
    }
  }
}
