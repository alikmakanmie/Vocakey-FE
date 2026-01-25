import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../models/song_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource localDatasource;

  HomeRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, String?>> getRecentNote() async {
    try {
      final note = await localDatasource.getRecentNote();
      return Right(note);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> getFeaturedSongs() async {
    try {
      // ✅ FIXED: Use proper constructor with new keyword
      final List<Song> songs = <Song>[
        const SongModel(
          id: '1',
          title: 'Ratna Anjing',
          artist: 'Artist A',
          originalNote: 'G Major',
          isMatchWithUserNote: true,
        ),
        const SongModel(
          id: '2',
          title: 'Kangen-Dewa',
          artist: 'Dewa 19',
          originalNote: 'C Major',
          isMatchWithUserNote: false,
        ),
        const SongModel(
          id: '3',
          title: 'Aku mau',
          artist: 'Artist C',
          originalNote: 'D Major',
          isMatchWithUserNote: false,
        ),
      ];
      return Right(songs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecentNote(String note) async {
    try {
      await localDatasource.saveRecentNote(note);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
