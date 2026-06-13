import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_event_repository.dart';
import '../../../data/repositories/network_event_repository_impl.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final IEventRepository _eventRepository;

  EventCubit(this._eventRepository) : super(EventInitial());

  Future<void> fetchEvents() async {
    emit(EventLoading());
    try {
      final events = await _eventRepository.getUpcomingCircles();
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  void bookEvent(String eventTitle) {
    if (state is EventLoaded) {
      final currentEvents = (state as EventLoaded).events;
      final updatedEvents = currentEvents.map((e) {
        if (e.title == eventTitle) {
          final updated = e.copyWith(
            isBookedByUser: true,
            joinedCount: e.joinedCount + 1,
          );
          if (_eventRepository is NetworkEventRepositoryImpl) {
            (_eventRepository as NetworkEventRepositoryImpl).updateEventBooking(updated);
          }
          return updated;
        }
        return e;
      }).toList();
      emit(EventLoaded(updatedEvents));
    }
  }

  void confirmScan(String eventTitle) {
    if (state is EventLoaded) {
      final currentEvents = (state as EventLoaded).events;
      final updatedEvents = currentEvents.map((e) {
        if (e.title == eventTitle) {
          final updated = e.copyWith(
            confirmedAttendeeCount: e.confirmedAttendeeCount + 1,
          );
          if (_eventRepository is NetworkEventRepositoryImpl) {
            (_eventRepository as NetworkEventRepositoryImpl).updateEventBooking(updated);
          }
          return updated;
        }
        return e;
      }).toList();
      emit(EventLoaded(updatedEvents));
    }
  }
}
