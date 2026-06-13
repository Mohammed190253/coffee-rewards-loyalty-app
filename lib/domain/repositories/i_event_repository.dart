import '../entities/event_circle.dart';

abstract class IEventRepository {
  Future<List<EventCircle>> getUpcomingCircles();
}
