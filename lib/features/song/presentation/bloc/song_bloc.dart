import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_songs.dart';
import '../../domain/usecases/search_songs.dart';
import '../../domain/usecases/get_song_detail.dart';
import 'song_event.dart';
import 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final GetSongs getSongs;
  final SearchSongs searchSongs;
  final GetSongDetail getSongDetail;

  SongBloc({
    required this.getSongs,
    required this.searchSongs,
    required this.getSongDetail,
  }) : super(SongInitial()) {
    on<LoadSongsEvent>(_onLoadSongs);
    on<SearchSongsEvent>(_onSearchSongs);
    on<LoadSongDetailEvent>(_onLoadSongDetail);
    on<TransposeSongEvent>(_onTransposeSong);
  }

  Future<void> _onLoadSongs(
    LoadSongsEvent event,
    Emitter<SongState> emit,
  ) async {
    emit(SongLoading());

    final result = await getSongs(category: event.category);

    result.fold(
      (failure) => emit(SongError(failure.message)),
      (songs) => emit(SongListLoaded(
        songs: songs,
        selectedCategory: event.category,
      )),
    );
  }

  Future<void> _onSearchSongs(
    SearchSongsEvent event,
    Emitter<SongState> emit,
  ) async {
    emit(SongLoading());

    final result = await searchSongs(event.query);

    result.fold(
      (failure) => emit(SongError(failure.message)),
      (songs) => emit(SongListLoaded(songs: songs)),
    );
  }

  Future<void> _onLoadSongDetail(
    LoadSongDetailEvent event,
    Emitter<SongState> emit,
  ) async {
    emit(SongLoading());

    final result = await getSongDetail(event.songId);

    result.fold(
      (failure) => emit(SongError(failure.message)),
      (detail) => emit(SongDetailLoaded(detail)),
    );
  }

  void _onTransposeSong(
    TransposeSongEvent event,
    Emitter<SongState> emit,
  ) {
    if (state is SongDetailLoaded) {
      final currentState = state as SongDetailLoaded;
      final updatedDetail = currentState.songDetail.copyWith(
        transposeSemitone: event.semitone,
      );
      emit(SongDetailLoaded(updatedDetail));
    }
  }
}
