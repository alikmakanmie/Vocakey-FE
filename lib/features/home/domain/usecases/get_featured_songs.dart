import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song.dart';
import '../repositories/home_repository.dart';

class GetFeaturedSongs {
  final HomeRepository repository;

  GetFeaturedSongs(this.repository);

  Future<Either<Failure, List<Song>>> call() async {
    return await repository.getFeaturedSongs();
  }
}
