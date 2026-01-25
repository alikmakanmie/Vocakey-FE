import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({Key? key}) : super(key: key);

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen>
    with SingleTickerProviderStateMixin {
  
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  Timer? _durationTimer;
  
  bool _isRecording = false;
  int _recordDuration = 0;
  List<double> _audioLevels = List<double>.generate(20, (_) => 0.0, growable: true);
  double _currentAmplitude = 0.0;
  String? _recordingPath;  // ✅ Simpan path recording

  static const double _minDb = -45.0;
  static const int _maxBars = 20;

  @override
  void initState() {
    super.initState();
  }

  // ✅ Generate path dengan path_provider
  Future<String> _getRecordingPath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/vocakey_$timestamp.wav';
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final path = await _getRecordingPath();
        
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: path,  // ✅ Required parameter
        );
        
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _recordingPath = path;
        });
        
        _durationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            setState(() {
              _recordDuration++;
            });
            
            // ✅ Auto stop setelah 10 detik
            if (_recordDuration >= 10) {
              _stopRecording();
            }
          },
        );
        
        _timer = Timer.periodic(
          const Duration(milliseconds: 50),
          (timer) async {
            await _updateSpectrum();
          },
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _durationTimer?.cancel();
    
    final path = await _audioRecorder.stop();
    
    setState(() {
      _isRecording = false;
      _audioLevels = List<double>.generate(_maxBars, (_) => 0.0, growable: true);
      _currentAmplitude = 0.0;
    });
    
    if (path != null) {
      print('✅ Recording saved at: $path');
      _recordingPath = path;
      
      // ✅ Tampilkan dialog atau kirim ke backend
      _showRecordingComplete(path);
    }
  }

  void _showRecordingComplete(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(_recordDuration)}'),
            const SizedBox(height: 8),
            Text('File: ${path.split('/').last}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Upload ke backend
              _uploadToBackend(path);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadToBackend(String filePath) async {
    // TODO: Implementasi upload ke Vocakey-BE-V2
    print('Uploading file: $filePath');
    // Gunakan dio untuk upload seperti di project Anda
  }

  Future<void> _updateSpectrum() async {
    try {
      final amplitude = await _audioRecorder.getAmplitude();
      final currentDb = amplitude.current;
      
      if (currentDb.isFinite && currentDb > _minDb) {
        final normalized = ((currentDb - _minDb) / (-_minDb))
            .clamp(0.0, 1.0);
        
        setState(() {
          _currentAmplitude = normalized;
          _audioLevels.removeAt(0);
          _audioLevels.add(normalized);
        });
      }
    } catch (e) {
      print('Error updating spectrum: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6BA5D6),
              Color(0xFF9B7FD6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_isRecording) {
                          _stopRecording();
                        }
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Merekam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Tentukan Suara Nada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dasar Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const Spacer(),
              
              Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: AudioSpectrumPainter(
                    audioLevels: _audioLevels,
                    isRecording: _isRecording,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: const Color(0xFF6BA5D6),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_recordDuration),
                        style: const TextStyle(
                          color: Color(0xFF6BA5D6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _isRecording ? 'Sedang Merekam...' : 'Tap untuk merekam',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (_isRecording)
                Text(
                  '$_recordDuration/10 detik',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}

class AudioSpectrumPainter extends CustomPainter {
  final List<double> audioLevels;
  final bool isRecording;

  AudioSpectrumPainter({
    required this.audioLevels,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final barWidth = 4.0;
    final spacing = 8.0;
    final totalWidth = (barWidth + spacing) * audioLevels.length;
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < audioLevels.length; i++) {
      final level = audioLevels[i];
      
      final barHeight = isRecording 
          ? (level * size.height * 0.8).clamp(4.0, size.height * 0.8)
          : 4.0;
      
      final x = startX + (i * (barWidth + spacing));
      final y = (size.height - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      
      final opacity = isRecording 
          ? (0.3 + (i / audioLevels.length) * 0.7)
          : 0.3;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioSpectrumPainter oldDelegate) {
    return oldDelegate.audioLevels != audioLevels ||
           oldDelegate.isRecording != isRecording;
  }
}
