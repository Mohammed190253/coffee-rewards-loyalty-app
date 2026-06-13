import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/network_config.dart';
import '../../domain/entities/stamp_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_user_repository.dart';

/// Customer registration (name, phone, gender, password) is handled by
/// [AuthRepositoryImpl] after OTP verification — see `auth_repository_impl.dart`.
class UserRepositoryImpl implements IUserRepository {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'astro_jwt_token';
  static const _nameKey = 'astro_user_name';

  final http.Client _client;
  final String _baseUrl;

  UserRepositoryImpl({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? NetworkConfig.apiBaseUrl;

  @override
  Future<User> getUserProfile() async {
    final token = await _storage.read(key: _tokenKey);
    final cachedName = await _storage.read(key: _nameKey);

    String displayName = cachedName?.trim().isNotEmpty == true
        ? cachedName!.trim()
        : 'Guest Voyager';

    if (token != null && token.isNotEmpty) {
      try {
        final response = await _client
            .get(
              Uri.parse('$_baseUrl/api/auth/me'),
              headers: {
                'Authorization': 'Bearer $token',
                'bypass-tunnel-reminder': 'true',
              },
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final resolvedName = (data['name'] as String?)?.trim();
          if (resolvedName != null && resolvedName.isNotEmpty) {
            displayName = resolvedName;
            await _storage.write(key: _nameKey, value: displayName);
          }
        }
      } catch (_) {
        // Fall back to cached name or demo defaults below.
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    return User(
      name: displayName,
      currentStars: 1240,
      totalStarsForNextTier: 2000,
      tierName: 'Voyager Level 4',
      walletBalance: 24.50,
      qrCodeData: 'USER_${displayName.hashCode.abs()}_ASTRO',
      earnedStamps: _defaultStamps(),
    );
  }

  static Future<void> cacheSessionName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      await _storage.write(key: _nameKey, value: trimmed);
    }
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _nameKey);
  }

  static List<StampModel> _defaultStamps() {
    return [
      StampModel(
        id: 'ibn_battuta',
        title: 'The Ibn Battuta Explorer Stamp',
        description: 'Completed a 25-minute deep focus session',
        iconData: Icons.explore_outlined,
        isUnlocked: false,
      ),
      StampModel(
        id: 'al_khwarizmi',
        title: 'The Al-Khwarizmi Focus Ring',
        description: 'Completed a 45-minute deep focus session',
        iconData: Icons.auto_awesome,
        isUnlocked: false,
      ),
      StampModel(
        id: 'celestial_navigator',
        title: 'The Celestial Navigator Stamp',
        description: 'Completed a 60-minute deep focus session',
        iconData: Icons.compass_calibration_outlined,
        isUnlocked: false,
      ),
      StampModel(
        id: 'scholar_laureate',
        title: 'The Scholar Laureate Stamp',
        description: 'Completed a 90-minute deep focus session',
        iconData: Icons.workspace_premium,
        isUnlocked: false,
      ),
    ];
  }
}
