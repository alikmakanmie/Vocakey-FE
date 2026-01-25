import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/song_detail.dart';
import '../repositories/song_repository.dart';

class GetSongDetail {
  final SongRepository repository;

  GetSongDetail(this.repository);

  Future<Either<Failure, SongDetail>> call(String id) async {
    return await repository.getSongDetail(id);
  }
}
