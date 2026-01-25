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

/// ✅ NEW: Event untuk update recording progress
/// Dipanggil setiap detik atau setiap ada perubahan amplitude
class UpdateRecordingProgressEvent extends PitchEvent {
  /// Durasi recording saat ini (dalam detik)
  final int duration;
  
  /// Audio amplitude (0.0 - 1.0) untuk visualisasi waveform
  final double amplitude;

  UpdateRecordingProgressEvent({
    required this.duration,
    this.amplitude = 0.0,
  });

  @override
  List<Object?> get props => [duration, amplitude];
}

/// Event untuk analyze audio setelah recording selesai
class AnalyzeAudioEvent extends PitchEvent {
  final String audioPath;

  AnalyzeAudioEvent(this.audioPath);

  @override
  List<Object?> get props => [audioPath];
}

/// ✅ NEW: Event untuk update analysis progress
/// Dipanggil saat backend sedang proses analisis
class UpdateAnalysisProgressEvent extends PitchEvent {
  /// Progress (0.0 - 1.0)
  final double progress;
  
  /// Status message untuk ditampilkan
  final String statusMessage;

  UpdateAnalysisProgressEvent({
    required this.progress,
    this.statusMessage = 'Analyzing...',
  });

  @override
  List<Object?> get props => [progress, statusMessage];
}

/// Event untuk retry recording (setelah error atau hasil tidak memuaskan)
class RetryRecordingEvent extends PitchEvent {}

/// ✅ NEW: Event untuk reset state ke initial
/// Berguna setelah success dan user ingin record lagi
class ResetPitchStateEvent extends PitchEvent {}

/// ✅ NEW: Event untuk request microphone permission
class RequestMicrophonePermissionEvent extends PitchEvent {}

/// ✅ NEW: Event untuk cancel/abort analysis yang sedang berjalan
class CancelAnalysisEvent extends PitchEvent {}
