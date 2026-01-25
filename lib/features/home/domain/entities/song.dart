import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String originalNote;
  final String? albumCover;
  final bool isMatchWithUserNote;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.originalNote,
    this.albumCover,
    this.isMatchWithUserNote = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    originalNote,
    albumCover,
    isMatchWithUserNote,
  ];
}
