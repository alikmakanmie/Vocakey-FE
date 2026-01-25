import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';

abstract class HomeRepository {
  Future<Either<Failure, String?>> getRecentNote();
  Future<Either<Failure, List<Song>>> getFeaturedSongs();
  Future<Either<Failure, void>> saveRecentNote(String note);
}
