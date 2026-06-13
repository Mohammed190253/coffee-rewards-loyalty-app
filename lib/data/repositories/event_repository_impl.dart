import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network_config.dart';
import '../../domain/entities/event_circle.dart';
import '../../domain/repositories/i_event_repository.dart';
import '../models/event_serialization_contract.dart';

/// Concrete implementation that fetches upcoming event circles from the backend.
/// Falls back to static mock data when the server is unreachable.
class EventRepositoryImpl implements IEventRepository {
  final http.Client _client;
  final String _baseUrl;
  final FlutterSecureStorage _storage;

  EventRepositoryImpl({http.Client? client, String? baseUrl, FlutterSecureStorage? storage})
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
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<List<EventCircle>> getUpcomingCircles() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/events'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
          return jsonList
              .map((item) => EventCircleDto.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (e, stackTrace) {
          developer.log('Core Error: Failed parsing events JSON', error: e, stackTrace: stackTrace);
          return _fallbackCircles();
        }
      } else {
        return _fallbackCircles();
      }
    } catch (e) {
      developer.log('Core Error: Failed to fetch events: $e');
      return _fallbackCircles();
    }
  }

  List<EventCircle> _fallbackCircles() {
    return [
      EventCircle(
        title: "The Traveler Circle",
        topic: "Desert Navigation & Stories",
        date: "May 20, 2026",
        time: "7:00 PM",
        price: "10.00 JOD",
        location: "Abdoun Branch",
        imagePath: "https://images.unsplash.com/photo-1539635278303-d4002c07eae3?q=80&w=400",
        isFree: false,
        ticketPrice: 10.00,
        maxCapacity: 15,
        joinedCount: 12,
        isBookedByUser: false,
        confirmedAttendeeCount: 0,
      ),
      EventCircle(
        title: "The Scholar Circle",
        topic: "Arabic Poetry Analysis",
        date: "May 22, 2026",
        time: "6:30 PM",
        price: "Free",
        location: "Dabouq Branch",
        imagePath: "https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=400",
        isFree: true,
        ticketPrice: 0.00,
        maxCapacity: 30,
        joinedCount: 28,
        isBookedByUser: false,
        confirmedAttendeeCount: 0,
      ),
    ];
  }
}
