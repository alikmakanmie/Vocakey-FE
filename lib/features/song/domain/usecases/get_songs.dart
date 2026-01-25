import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/song.dart';
import '../repositories/song_repository.dart';

class GetSongs {
  final SongRepository repository;

  GetSongs(this.repository);

  Future<Either<Failure, List<Song>>> call({String? category}) async {
    return await repository.getSongs(category: category);
  }
}
