import 'package:equatable/equatable.dart';

import '../../domain/entities/analysis_result.dart';

/// Base class untuk semua Pitch States
abstract class PitchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state sebelum recording dimulai
class PitchInitial extends PitchState {}

/// State saat recording sedang berlangsung
class PitchRecording extends PitchState {
  final int duration;
  final double amplitude;
  final bool isRecording;

  PitchRecording({
    required this.duration,
    this.amplitude = 0.0,
    this.isRecording = true,
  });

  @override
  List<Object> get props => [duration, amplitude, isRecording];

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// State setelah recording selesai
class PitchRecordingComplete extends PitchState {
  final String audioPath;
  final int totalDuration;

  PitchRecordingComplete(this.audioPath, {this.totalDuration = 0});

  @override
  List<Object> get props => [audioPath, totalDuration];
}

/// State saat analisis sedang berlangsung
class PitchAnalyzing extends PitchState {
  final double progress;
  final String statusMessage;

  PitchAnalyzing({
    this.progress = 0.0,
    this.statusMessage = 'Analyzing audio...',
  });

  @override
  List<Object> get props => [progress, statusMessage];

  int get progressPercentage => (progress * 100).round();
}

/// State saat analisis berhasil
class PitchAnalysisSuccess extends PitchState {
  final AnalysisResult result;

  PitchAnalysisSuccess(this.result);

  @override
  List<Object> get props => [result];
}

/// State saat analisis error
class PitchAnalysisError extends PitchState {
  final String message;
  final String? errorCode;

  PitchAnalysisError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// State saat permission microphone ditolak
class PitchPermissionDenied extends PitchState {
  final String message;

  PitchPermissionDenied({
    this.message = 'Microphone permission is required to record audio',
  });

  @override
  List<Object> get props => [message];
}

/// State saat recording dibatalkan/stopped
class PitchRecordingStopped extends PitchState {
  final String? audioPath;
  final int duration;

  PitchRecordingStopped({
    this.audioPath,
    required this.duration,
  });

  @override
  List<Object?> get props => [audioPath, duration];
}

/// State untuk idle (after success, user bisa record lagi)
class PitchIdle extends PitchState {}
