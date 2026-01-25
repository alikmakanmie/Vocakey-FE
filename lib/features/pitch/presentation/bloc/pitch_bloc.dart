import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/analyze_audio.dart';
import 'pitch_event.dart';
import 'pitch_state.dart';

class PitchBloc extends Bloc<PitchEvent, PitchState> {
  final AnalyzeAudio analyzeAudio;

  PitchBloc({required this.analyzeAudio}) : super(PitchInitial()) {
    on<AnalyzeAudioEvent>(_onAnalyzeAudio);
  }

  Future<void> _onAnalyzeAudio(
    AnalyzeAudioEvent event,
    Emitter<PitchState> emit,
  ) async {
    print('🔵 BLoC: Starting analysis...');
    print('   Audio path: ${event.audioPath}');

    // Progress 0%
    emit(PitchAnalyzing(
      progress: 0.0,
      statusMessage: 'Initializing...',
    ));
    print('📊 Progress: 0% - Initializing...');
    await Future.delayed(const Duration(milliseconds: 800));

    // Progress 30%
    emit(PitchAnalyzing(
      progress: 0.3,
      statusMessage: 'Uploading audio...',
    ));
    print('📊 Progress: 30% - Uploading audio...');
    await Future.delayed(const Duration(milliseconds: 600));

    // Progress 60%
    emit(PitchAnalyzing(
      progress: 0.6,
      statusMessage: 'Detecting pitch...',
    ));
    print('📊 Progress: 60% - Detecting pitch...');

    // Call API
    final result = await analyzeAudio(event.audioPath);

    // Check if emitter is still active
    if (emit.isDone) {
      print('⚠️ BLoC: Emitter already closed, skipping emit');
      return;
    }

    // Extract hasil dan emit
    await result.fold(
      (failure) async {
        print('❌ BLoC: Analysis failed - ${failure.message}');
        emit(PitchAnalysisError(failure.message));
        print('🔴 BLoC: State emitted - PitchAnalysisError');
      },
      (success) async {
        print('✅ BLoC: Analysis success!');
        print('   Base Note: ${success.baseNote}');
        print('   Base Frequency: ${success.baseFrequency} Hz');
        print('   Song Key: ${success.fullKey}');
        print('   Confidence: ${success.confidencePercentage.toStringAsFixed(1)}%');
        print('   Recommendations: ${success.recommendations.length} songs');

        // Progress 90%
        emit(PitchAnalyzing(
          progress: 0.9,
          statusMessage: 'Finalizing...',
        ));
        print('📊 Progress: 90% - Finalizing...');

        // Await delay before final emit
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if still active before final emit
        if (!emit.isDone) {
          emit(PitchAnalysisSuccess(success));
          print('🟢 BLoC: State emitted - PitchAnalysisSuccess');
        }
      },
    );
  }
}
