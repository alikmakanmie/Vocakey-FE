import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analysis_result.dart';

abstract class PitchRepository {
  Future<Either<Failure, AnalysisResult>> analyzeAudio(String audioPath);
}