import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/pitch_repository.dart';
import '../datasources/pitch_remote_datasource.dart';

class PitchRepositoryImpl implements PitchRepository {
  final PitchRemoteDatasource remoteDatasource;
  
  PitchRepositoryImpl(this.remoteDatasource);
  
  @override
  Future<Either<Failure, AnalysisResult>> analyzeAudio(String audioPath) async {
    try {
      final result = await remoteDatasource.analyzeAudio(audioPath);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
