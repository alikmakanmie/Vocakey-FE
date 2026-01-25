import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // ✅ Constructor tanpa parameter
  HomeBloc() : super(HomeInitial()) {
    on<LoadLastAnalysisEvent>(_onLoadLastAnalysis);
  }
  
  Future<void> _onLoadLastAnalysis(
    LoadLastAnalysisEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    
    try {
      final lastAnalysis = await LocalStorageService.getLastAnalysis();
      
      if (lastAnalysis != null) {
        emit(HomeAnalysisLoaded(
          note: lastAnalysis['note'] ?? 'G',
          vocalRange: lastAnalysis['vocal_range'] ?? 'Unknown',
          accuracy: (lastAnalysis['accuracy'] ?? 0.0).toDouble(),
          vocalType: lastAnalysis['vocal_type'],
        ));
      } else {
        // Default state jika belum pernah analisis
        emit(HomeAnalysisLoaded(
          note: 'G',
          vocalRange: 'Belum Dianalisis',
          accuracy: 0.0,
        ));
      }
    } catch (e) {
      emit(HomeError('Failed to load last analysis: $e'));
    }
  }
}
