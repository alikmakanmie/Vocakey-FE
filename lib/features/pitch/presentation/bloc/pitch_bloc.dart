import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/analyze_audio.dart';
import 'pitch_event.dart';
import 'pitch_state.dart';

class PitchBloc extends Bloc<PitchEvent, PitchState> {
  final AnalyzeAudio analyzeAudio;

  PitchBloc({required this.analyzeAudio}) : super(PitchInitial()) {
    on<AnalyzeAudioEvent>(_onAnalyzeAudio);
    on<ResetPitchEvent>(_onReset);
    on<RetryRecordingEvent>(_onRetry);
  }

  Future<void> _onAnalyzeAudio(
    AnalyzeAudioEvent event,
    Emitter<PitchState> emit,
  ) async {
    print('🔵 BLoC: Starting analysis...');
    print('   Audio path: ${event.audioPath}');

    emit(PitchAnalyzing(progress: 0.0, statusMessage: 'Initializing...'));
    await Future.delayed(const Duration(milliseconds: 800));

    emit(PitchAnalyzing(progress: 0.3, statusMessage: 'Uploading audio...'));
    await Future.delayed(const Duration(milliseconds: 600));

    emit(PitchAnalyzing(progress: 0.6, statusMessage: 'Detecting pitch...'));

    final result = await analyzeAudio(event.audioPath);

    if (emit.isDone) {
      print('⚠️  BLoC: Emitter already closed, skipping emit');
      return;
    }

    await result.fold(
      (failure) async {
        print('❌ BLoC: Analysis failed - ${failure.message}');
        emit(PitchAnalysisError(failure.message));
      },
      (success) async {
        // ✅ SIMPLE: Langsung emit success, biar UI yang handle empty recommendations
        print('✅ BLoC: Analysis success!');
        print('   Base Note: ${success.baseNote}');
        print('   Recommendations: ${success.recommendations.length} songs');

        emit(PitchAnalyzing(progress: 0.9, statusMessage: 'Finalizing...'));
        await Future.delayed(const Duration(milliseconds: 500));

        if (!emit.isDone) {
          emit(PitchAnalysisSuccess(success));
          print('🟢 BLoC: State emitted - PitchAnalysisSuccess');
        }
      },
    );
  }

  void _onReset(ResetPitchEvent event, Emitter<PitchState> emit) {
    print('🔄 BLoC: Resetting to initial state');
    emit(PitchInitial());
  }

  void _onRetry(RetryRecordingEvent event, Emitter<PitchState> emit) {
    print('🔄 BLoC: Retry recording');
    emit(PitchInitial());
  }
}
