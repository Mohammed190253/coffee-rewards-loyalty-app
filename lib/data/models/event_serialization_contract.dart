import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/event_circle.dart';
import '../../domain/repositories/i_event_repository.dart';

/// EventCircleDto establishes Dart serialization contract ('fromJson' and 'toJson')
/// to seamlessly map adjustments made on the Web Admin panel to our mobile frontend.
class EventCircleDto extends EventCircle {
  EventCircleDto({
    required super.title,
    required super.topic,
    required super.date,
    required super.time,
    required super.price,
    required super.location,
    required super.imagePath,
    required super.isFree,
    required super.ticketPrice,
    required super.maxCapacity,
    required super.joinedCount,
    required super.isBookedByUser,
    required super.confirmedAttendeeCount,
  });

  /// Factory constructor to deserialize from JSON map received from backend REST API / Web Panel
  factory EventCircleDto.fromJson(Map<String, dynamic> json) {
    return EventCircleDto(
      title: json['title'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      price: json['price'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? true,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0.0,
      maxCapacity: json['maxCapacity'] as int? ?? 0,
      joinedCount: json['joinedCount'] as int? ?? 0,
      isBookedByUser: json['isBookedByUser'] as bool? ?? false,
      confirmedAttendeeCount: json['confirmedAttendeeCount'] as int? ?? 0,
    );
  }

  /// Serialize the object to JSON format for synchronization back to cloud database
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'topic': topic,
      'date': date,
      'time': time,
      'price': price,
      'location': location,
      'imagePath': imagePath,
      'isFree': isFree,
      'ticketPrice': ticketPrice,
      'maxCapacity': maxCapacity,
      'joinedCount': joinedCount,
      'isBookedByUser': isBookedByUser,
      'confirmedAttendeeCount': confirmedAttendeeCount,
    };
  }
}

