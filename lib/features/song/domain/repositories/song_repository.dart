import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/song.dart';
import '../entities/song_detail.dart';

abstract class SongRepository {
  Future<Either<Failure, List<Song>>> getSongs({String? category});
  Future<Either<Failure, List<Song>>> searchSongs(String query);
  Future<Either<Failure, SongDetail>> getSongDetail(String id);
  Future<Either<Failure, String>> transposeSong(String id, int semitone);
}
