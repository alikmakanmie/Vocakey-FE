class SongModel {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String? thumbnail;
  final String? album;
  final String youtubeUrl;
  final String youtubeWatchUrl;
  final String videoId;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.thumbnail,
    this.album,
    required this.youtubeUrl,
    required this.youtubeWatchUrl,
    required this.videoId,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      artist: json['artist'] as String? ?? 'Unknown',
      duration: json['duration'] as String? ?? 'Unknown',
      thumbnail: json['thumbnail'] as String?,
      album: json['album'] as String?,
      youtubeUrl: json['youtube_url'] as String? ?? '',
      youtubeWatchUrl: json['youtube_watch_url'] as String? ?? '',
      videoId: json['video_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'thumbnail': thumbnail,
      'album': album,
      'youtube_url': youtubeUrl,
      'youtube_watch_url': youtubeWatchUrl,
      'video_id': videoId,
    };
  }
}
