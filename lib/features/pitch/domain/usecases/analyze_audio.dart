import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analysis_result.dart';
import '../repositories/pitch_repository.dart';

class AnalyzeAudio {
  final PitchRepository repository;
  
  AnalyzeAudio(this.repository);
  
  Future<Either<Failure, AnalysisResult>> call(String audioPath) async {
    return await repository.analyzeAudio(audioPath);
  }
}
