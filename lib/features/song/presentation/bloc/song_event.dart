import 'package:equatable/equatable.dart';

abstract class SongEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSongsEvent extends SongEvent {
  final String? category;

  LoadSongsEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class SearchSongsEvent extends SongEvent {
  final String query;

  SearchSongsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadSongDetailEvent extends SongEvent {
  final String songId;

  LoadSongDetailEvent(this.songId);

  @override
  List<Object?> get props => [songId];
}

class TransposeSongEvent extends SongEvent {
  final int semitone;

  TransposeSongEvent(this.semitone);

  @override
  List<Object?> get props => [semitone];
}
