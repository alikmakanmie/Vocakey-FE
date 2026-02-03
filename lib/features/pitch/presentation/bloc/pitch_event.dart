import 'package:equatable/equatable.dart';

/// Base class untuk semua Pitch Events
abstract class PitchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event untuk memulai recording
class StartRecordingEvent extends PitchEvent {}

/// Event untuk menghentikan recording
class StopRecordingEvent extends PitchEvent {}

/// Event untuk analyze audio setelah recording selesai
class AnalyzeAudioEvent extends PitchEvent {
  final String audioPath;

  AnalyzeAudioEvent(this.audioPath);

  @override
  List<Object?> get props => [audioPath];
}

/// ✅ NEW: Event untuk reset state ke initial
/// Berguna setelah success dan user ingin record lagi
class ResetPitchEvent extends PitchEvent {}

/// ✅ NEW: Event untuk retry recording (setelah error atau hasil tidak memuaskan)
class RetryRecordingEvent extends PitchEvent {}
