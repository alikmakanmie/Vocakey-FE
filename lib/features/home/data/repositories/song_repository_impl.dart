import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/song.dart';
import '../../../home/data/models/song_model.dart';
import '../../domain/entities/song_detail.dart';
import '../../domain/repositories/song_repository.dart';
import '../models/song_detail_model.dart';

class SongRepositoryImpl implements SongRepository {
  @override
  Future<Either<Failure, List<Song>>> getSongs({String? category}) async {
    try {
      // ✅ FIXED: Use proper type declaration
      final List<Song> songs = <Song>[
        const SongModel(
          id: '1',
          title: 'Judul Lagu 1',
          artist: 'Artis A',
          originalNote: 'G Major',
          isMatchWithUserNote: true,
        ),
        const SongModel(
          id: '2',
          title: 'Judul Lagu 2',
          artist: 'Artis A',
          originalNote: 'G Major',
          isMatchWithUserNote: false,
        ),
        const SongModel(
          id: '3',
          title: 'Judul Lagu 3',
          artist: 'Artis A',
          originalNote: 'G Major',
          isMatchWithUserNote: false,
        ),
      ];

      return Right(songs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> searchSongs(String query) async {
    try {
      final allSongs = await getSongs();
      return allSongs.fold(
        (failure) => Left(failure),
        (songs) {
          final filtered = songs.where((song) {
            return song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase());
          }).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SongDetail>> getSongDetail(String id) async {
    try {
      const detail = SongDetailModel(
        id: '1',
        title: 'Judul Lagu I - Artis A',
        artist: 'Artis A',
        originalNote: 'G Mayor',
        userNote: 'G Mayor',
        isDirectMatch: true,
        videoUrl: 'https://example.com/video',
      );

      return const Right(detail);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> transposeSong(String id, int semitone) async {
    try {
      final transposedNote = 'Transposed ${semitone > 0 ? '+' : ''}$semitone';
      return Right(transposedNote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
