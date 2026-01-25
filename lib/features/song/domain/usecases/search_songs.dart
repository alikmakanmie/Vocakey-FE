import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/song.dart';
import '../repositories/song_repository.dart';

class SearchSongs {
  final SongRepository repository;

  SearchSongs(this.repository);

  Future<Either<Failure, List<Song>>> call(String query) async {
    return await repository.searchSongs(query);
  }
}
