import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sanctuary_state.dart';

class SanctuaryCubit extends Cubit<SanctuaryState> {
  Timer? _timer;

  SanctuaryCubit() : super(const SanctuaryState());

  void toggleTimer() {
    if (state.isTimerRunning) {
      _timer?.cancel();
      emit(state.copyWith(isTimerRunning: false));
    } else {
      int startSeconds = state.timerSeconds == 0 ? state.focusDurationSeconds : state.timerSeconds;
      emit(state.copyWith(isTimerRunning: true, timerSeconds: startSeconds));
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.timerSeconds > 1) {
          emit(state.copyWith(timerSeconds: state.timerSeconds - 1));
        } else if (state.timerSeconds == 1) {
          _timer?.cancel();
          emit(state.copyWith(
            isTimerRunning: false,
            timerSeconds: 0,
          )); // Hits 0 naturally, stays at 0 until claimed/reset
        } else {
          _timer?.cancel();
          emit(state.copyWith(isTimerRunning: false));
        }
      });
    }
  }

  void adjustTimer(int deltaSeconds) {
    if (!state.isTimerRunning) {
      final newDuration = state.focusDurationSeconds + deltaSeconds;
      if (newDuration >= 60) { // Keep it at least 1 minute (60 seconds)
        emit(state.copyWith(
          focusDurationSeconds: newDuration,
          timerSeconds: newDuration, // Instantly updates countdown display!
        ));
      }
    }
  }

  void resetTimer() {
    _timer?.cancel();
    emit(state.copyWith(
      isTimerRunning: false, 
      timerSeconds: state.focusDurationSeconds,
    )); // Reset to custom baseline focus duration
  }

  void toggleSoundTrack(String trackName) {
    if (state.activeSoundTrack == trackName) {
      // Turn off if tapping the active one
      emit(state.copyWith(activeSoundTrack: ""));
    } else {
      emit(state.copyWith(activeSoundTrack: trackName));
    }
  }

  void addQuickNote(String note) {
    if (note.trim().isNotEmpty) {
      final updatedNotes = List<String>.from(state.quickNotes)..insert(0, note.trim());
      emit(state.copyWith(quickNotes: updatedNotes));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
