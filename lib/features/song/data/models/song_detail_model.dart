import '../../domain/entities/song_detail.dart';

class SongDetailModel extends SongDetail {
  const SongDetailModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.originalNote,
    super.userNote,
    super.albumCover,
    super.videoUrl,
    super.lyrics,
    super.isDirectMatch,
    super.transposeSemitone,
  });

  factory SongDetailModel.fromJson(Map<String, dynamic> json) {
    return SongDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['judul'] ?? '',
      artist: json['artist'] ?? json['artis'] ?? '',
      originalNote: json['original_note'] ?? json['nada_asli'] ?? '',
      userNote: json['user_note'] ?? json['nada_saya'],
      albumCover: json['album_cover'] ?? json['cover'],
      videoUrl: json['video_url'] ?? json['link_video'],
      lyrics: json['lyrics'] ?? json['lirik'],
      isDirectMatch: json['is_direct_match'] ?? json['cocok_langsung'] ?? false,
      transposeSemitone: json['transpose_semitone'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'original_note': originalNote,
      'user_note': userNote,
      'album_cover': albumCover,
      'video_url': videoUrl,
      'lyrics': lyrics,
      'is_direct_match': isDirectMatch,
      'transpose_semitone': transposeSemitone,
    };
  }
}
