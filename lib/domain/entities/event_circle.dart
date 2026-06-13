class EventCircle {
  final String title;
  final String topic;
  final String date;
  final String time;
  final String price; // Deprecated or kept for backwards compatibility
  final String location;
  final String imagePath;
  final bool isFree;
  final double ticketPrice;
  final int maxCapacity;
  final int joinedCount;
  final bool isBookedByUser;
  final int confirmedAttendeeCount;

  EventCircle({
    required this.title,
    required this.topic,
    required this.date,
    required this.time,
    required this.price,
    required this.location,
    required this.imagePath,
    required this.isFree,
    required this.ticketPrice,
    required this.maxCapacity,
    required this.joinedCount,
    required this.isBookedByUser,
    required this.confirmedAttendeeCount,
  });

  EventCircle copyWith({
    String? title,
    String? topic,
    String? date,
    String? time,
    String? price,
    String? location,
    String? imagePath,
    bool? isFree,
    double? ticketPrice,
    int? maxCapacity,
    int? joinedCount,
    bool? isBookedByUser,
    int? confirmedAttendeeCount,
  }) {
    return EventCircle(
      title: title ?? this.title,
      topic: topic ?? this.topic,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      isFree: isFree ?? this.isFree,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      joinedCount: joinedCount ?? this.joinedCount,
      isBookedByUser: isBookedByUser ?? this.isBookedByUser,
      confirmedAttendeeCount: confirmedAttendeeCount ?? this.confirmedAttendeeCount,
    );
  }
}
