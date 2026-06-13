import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/event_circle.dart';
import '../../domain/repositories/i_event_repository.dart';
import '../models/event_serialization_contract.dart';

/// Network event repository implementation utilizing the serialization DTO.
/// Includes automatic fallback to local mock events if the backend REST server is offline.
class NetworkEventRepositoryImpl implements IEventRepository {
  final http.Client client;
  final String apiBaseUrl;
  final FlutterSecureStorage _storage;

  NetworkEventRepositoryImpl({
    required this.client,
    required this.apiBaseUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

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
  Future<List<EventCircle>> getUpcomingCircles() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$apiBaseUrl/api/events'),
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
          return _getFallbackCircles();
        }
      } else {
        return _getFallbackCircles();
      }
    } catch (e) {
      developer.log('Core Error: Failed to fetch events: $e');
      return _getFallbackCircles();
    }
  }

  List<EventCircle> _getFallbackCircles() {
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

  /// Syncs updates (like client-side joins or scans) back to the local Node.js API
  Future<bool> updateEventBooking(EventCircle event) async {
    final dto = EventCircleDto(
      title: event.title,
      topic: event.topic,
      date: event.date,
      time: event.time,
      price: event.price,
      location: event.location,
      imagePath: event.imagePath,
      isFree: event.isFree,
      ticketPrice: event.ticketPrice,
      maxCapacity: event.maxCapacity,
      joinedCount: event.joinedCount,
      isBookedByUser: event.isBookedByUser,
      confirmedAttendeeCount: event.confirmedAttendeeCount,
    );

    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$apiBaseUrl/api/events/update'),
        headers: headers,
        body: json.encode(dto.toJson()),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Core Error: Failed to update event booking: $e');
      return false;
    }
  }
}
