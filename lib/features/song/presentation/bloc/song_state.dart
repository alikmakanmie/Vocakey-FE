import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/song.dart';
import '../../domain/entities/song_detail.dart';

abstract class SongState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongListLoaded extends SongState {
  final List<Song> songs;
  final String? selectedCategory;

  SongListLoaded({
    required this.songs,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [songs, selectedCategory];
}

class SongDetailLoaded extends SongState {
  final SongDetail songDetail;

  SongDetailLoaded(this.songDetail);

  @override
  List<Object?> get props => [songDetail];
}

class SongError extends SongState {
  final String message;

  SongError(this.message);

  @override
  List<Object?> get props => [message];
}
