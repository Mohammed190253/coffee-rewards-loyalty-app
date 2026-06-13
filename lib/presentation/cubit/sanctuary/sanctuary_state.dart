import 'package:equatable/equatable.dart';

class SanctuaryState extends Equatable {
  final int timerSeconds;
  final int focusDurationSeconds;
  final bool isTimerRunning;
  final String? activeSoundTrack;
  final List<String> quickNotes;

  const SanctuaryState({
    this.timerSeconds = 1500, // 25 minutes default Pomodoro
    this.focusDurationSeconds = 1500,
    this.isTimerRunning = false,
    this.activeSoundTrack,
    this.quickNotes = const [],
  });

  SanctuaryState copyWith({
    int? timerSeconds,
    int? focusDurationSeconds,
    bool? isTimerRunning,
    String? activeSoundTrack,
    List<String>? quickNotes,
  }) {
    return SanctuaryState(
      timerSeconds: timerSeconds ?? this.timerSeconds,
      focusDurationSeconds: focusDurationSeconds ?? this.focusDurationSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      activeSoundTrack: activeSoundTrack != null ? (activeSoundTrack.isEmpty ? null : activeSoundTrack) : this.activeSoundTrack,
      quickNotes: quickNotes ?? this.quickNotes,
    );
  }

  @override
  List<Object?> get props => [timerSeconds, focusDurationSeconds, isTimerRunning, activeSoundTrack, quickNotes];
}
