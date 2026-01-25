import 'package:equatable/equatable.dart';

class SongDetail extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String originalNote;
  final String? userNote;
  final String? albumCover;
  final String? videoUrl;
  final String? lyrics;
  final bool isDirectMatch;
  final int transposeSemitone;

  const SongDetail({
    required this.id,
    required this.title,
    required this.artist,
    required this.originalNote,
    this.userNote,
    this.albumCover,
    this.videoUrl,
    this.lyrics,
    this.isDirectMatch = false,
    this.transposeSemitone = 0,
  });

  SongDetail copyWith({
    int? transposeSemitone,
  }) {
    return SongDetail(
      id: id,
      title: title,
      artist: artist,
      originalNote: originalNote,
      userNote: userNote,
      albumCover: albumCover,
      videoUrl: videoUrl,
      lyrics: lyrics,
      isDirectMatch: isDirectMatch,
      transposeSemitone: transposeSemitone ?? this.transposeSemitone,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    originalNote,
    userNote,
    albumCover,
    videoUrl,
    lyrics,
    isDirectMatch,
    transposeSemitone,
  ];
}
