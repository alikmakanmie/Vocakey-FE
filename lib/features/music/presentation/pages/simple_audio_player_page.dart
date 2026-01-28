import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleAudioPlayerPage extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String artist;
  final String originalKey;
  final String? lyricsUrl;

  const SimpleAudioPlayerPage({
    Key? key,
    required this.audioUrl,
    required this.title,
    required this.artist,
    required this.originalKey,
    this.lyricsUrl,
  }) : super(key: key);

  @override
  State<SimpleAudioPlayerPage> createState() => _SimpleAudioPlayerPageState();
}

class _SimpleAudioPlayerPageState extends State<SimpleAudioPlayerPage> {
  late AudioPlayer _audioPlayer;
  late LyricController _lyricController;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _rawLyrics = '';
  bool _lyricsLoaded = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _lyricController = LyricController();

    _initAudio();
    _loadLyrics();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });

          _lyricController.setProgress(position);
        }
      });

      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration = duration ?? Duration.zero;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Error loading audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  Future<void> _loadLyrics() async {
    try {
      if (widget.lyricsUrl == null || widget.lyricsUrl!.isEmpty) {
        print('No lyrics URL provided');
        return;
      }

      print('🎵 Loading lyrics from: ${widget.lyricsUrl}');
      final uri = Uri.parse(widget.lyricsUrl!);
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final lyrics = data['lyrics'] as String? ?? '';

        if (lyrics.isNotEmpty) {
          _rawLyrics = lyrics;
          _lyricController.loadLyric(lyrics);

          setState(() => _lyricsLoaded = true);
          print('✅ Lyrics loaded successfully');
        }
      }
    } catch (e) {
      print('❌ Error loading lyrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAlbumArt(),
              const SizedBox(height: 20),
              _buildSongInfo(),
              const SizedBox(height: 20),

              Expanded(
                child: _buildLyrics(),
              ),

              _buildProgressBar(),
              _buildControls(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF2E4057),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.music_note_rounded,
        size: 80,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.artist,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6B9FE8).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Key: ${widget.originalKey}',
            style: const TextStyle(
              color: Color(0xFF6B9FE8),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLyrics() {
    if (!_lyricsLoaded || _rawLyrics.isEmpty) {
      return Center(
        child: Text(
          'Lyrics not available',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LyricView(
        controller: _lyricController,
        width: double.infinity,
        height: double.infinity,
        style: LyricStyles.default1.copyWith(
          textStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
          activeStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          lineGap: 12,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble() > 0
                  ? _totalDuration.inSeconds.toDouble()
                  : 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white54),
          iconSize: 40,
          onPressed: () {},
        ),
        const SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF1A1A2E),
            ),
            iconSize: 40,
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play();
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white54),
          iconSize: 40,
          onPressed: () {},
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _lyricController.dispose();
    super.dispose();
  }
}
