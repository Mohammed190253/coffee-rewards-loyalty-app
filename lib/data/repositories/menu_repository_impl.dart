import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network_config.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/i_menu_repository.dart';

class MenuRepositoryImpl implements IMenuRepository {
  final http.Client _client;
  final String _baseUrl;
  final FlutterSecureStorage _storage;

  MenuRepositoryImpl({http.Client? client, String? baseUrl, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl(),
        _storage = storage ?? const FlutterSecureStorage();

  static String _defaultBaseUrl() {
    return NetworkConfig.apiBaseUrl;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'astro_jwt_token');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'bypass-tunnel-reminder': 'true',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<List<MenuItem>> getAstrolabeMenu() async {
    final url = Uri.parse('$_baseUrl/api/menu');
    developer.log('Fetching menu from: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers).timeout(const Duration(seconds: 5));
      developer.log('Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
          return jsonList.map((item) {
            final map = item as Map<String, dynamic>;
            return MenuItem(
              name: map['name']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
              smallPrice: map['smallPrice'] != null ? (map['smallPrice'] as num).toDouble() : 0.0,
              regularPrice: map['regularPrice'] != null ? (map['regularPrice'] as num).toDouble() : null,
              category: map['category']?.toString() ?? 'General',
            );
          }).toList();
        } catch (e, stackTrace) {
          developer.log('Core Error: Failed parsing menu JSON', error: e, stackTrace: stackTrace);
          return _fallbackMenu();
        }
      } else {
        return _fallbackMenu();
      }
    } catch (e) {
      developer.log('Core Error: Failed to fetch menu: $e');
      return _fallbackMenu();
    }
  }

  @override
  Future<List<MenuItem>> getRecommendedItems() async {
    final url = Uri.parse('$_baseUrl/api/menu/recommendations');
    developer.log('Fetching recommendations from: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers).timeout(const Duration(seconds: 5));
      developer.log('Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
          return jsonList.map((item) {
            final map = item as Map<String, dynamic>;
            return MenuItem(
              name: map['name']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
              smallPrice: map['smallPrice'] != null ? (map['smallPrice'] as num).toDouble() : 0.0,
              regularPrice: map['regularPrice'] != null ? (map['regularPrice'] as num).toDouble() : null,
              category: map['category']?.toString() ?? 'General',
            );
          }).toList();
        } catch (e, stackTrace) {
          developer.log('Core Error: Failed parsing recommendations JSON', error: e, stackTrace: stackTrace);
          return _fallbackRecommendations();
        }
      } else {
        return _fallbackRecommendations();
      }
    } catch (e) {
      developer.log('Core Error: Failed to fetch recommendations: $e');
      return _fallbackRecommendations();
    }
  }

  // ---------- Fallback mock data ----------
  List<MenuItem> _fallbackMenu() => [
        MenuItem(name: "Signature Spanish Latte", description: "Smooth latte with a hint of caramel and a dash of cinnamon.", smallPrice: 3.25, regularPrice: 4.00, category: "Beverages"),
        MenuItem(name: "V60 Ethiopian Sidamo", description: "Bright, floral coffee brewed with precision V60 method.", smallPrice: 3.50, regularPrice: 4.25, category: "Beverages"),
        MenuItem(name: "Freshly Baked Croissant", description: "Buttery flaky pastry baked fresh every morning.", smallPrice: 2.50, category: "Bakery"),
        MenuItem(name: "Mineral Water", description: "Pure spring mineral water served chilled.", smallPrice: 1.00, category: "Beverages"),
      ];

  List<MenuItem> _fallbackRecommendations() => [
        MenuItem(name: "Signature Spanish Latte", description: "Smooth latte with a hint of caramel and a dash of cinnamon.", smallPrice: 3.25, regularPrice: 4.00, category: "Beverages"),
        MenuItem(name: "V60 Ethiopian Sidamo", description: "Bright, floral coffee brewed with precision V60 method.", smallPrice: 3.50, regularPrice: 4.25, category: "Beverages"),
      ];
}
