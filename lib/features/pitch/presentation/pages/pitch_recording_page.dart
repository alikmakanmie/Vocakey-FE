import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../bloc/pitch_bloc.dart';
import '../bloc/pitch_event.dart';
import '../bloc/pitch_state.dart';
import 'pitch_result_page.dart';
import 'pitch_loading_page.dart';

class PitchRecordingPage extends StatefulWidget {
  const PitchRecordingPage({Key? key}) : super(key: key);

  @override
  State<PitchRecordingPage> createState() => _PitchRecordingPageState();
}

class _PitchRecordingPageState extends State<PitchRecordingPage>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final PermissionService _permissionService = PermissionService();

  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isStopping = false; // ✅ NEW: Prevent double-stop
  int _recordDuration = 0;
  Timer? _timer;
  StreamSubscription<PitchState>? _blocSubscription;

  // Real-time audio amplitude
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  List<double> _amplitudes = List.filled(12, 0.2);
  double _currentDecibel = 0;
  double _maxDecibel = 20; // ✅ NEW: Track max decibel during recording

  // ✅ NEW: Auto-stop duration (8 seconds)
  static const int maxRecordingDuration = 8;
  // ✅ NEW: Minimum duration and volume thresholds for validation
  static const int minRecordingDuration = 2;
  static const double minDecibelThreshold = 30.0; // Minimum volume level

  @override
  void initState() {
    super.initState();
    _listenToBlocState();
    _noiseMeter = NoiseMeter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blocSubscription?.cancel();
    _noiseSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _listenToBlocState() {
  _blocSubscription = context.read<PitchBloc>().stream.listen((state) {
    if (!mounted) return;

    if (state is PitchAnalysisSuccess) {
      // Navigate ke result page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PitchResultPage(result: state.result),
        ),
      );
    } else if (state is PitchAnalysisError) {
      setState(() {
        _isAnalyzing = false;
      });
      
      // ✅ NEW: Kembali dari loading page ke recording page jika user sedang di loading page
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Pop dari PitchLoadingPage
      }
      
      // Tampilkan error dialog
      _showErrorDialog(state.message);
    }
  });
}



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Rekaman Gagal', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          message.isEmpty
              ? 'Suara tidak terdeteksi. Pastikan Anda bersenandung dengan jelas.'
              : message,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ NEW: Reset BLoC state sebelum kembali
              context.read<PitchBloc>().add(ResetPitchEvent());
              Navigator.pop(context); // Kembali ke home
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ NEW: Reset state BLoC terlebih dahulu
              context.read<PitchBloc>().add(ResetPitchEvent());
              // ✅ Reset recording state
              setState(() {
                _recordDuration = 0;
                _maxDecibel = 20;
                _amplitudes = List.filled(12, 0.2);
              });
              // Restart recording
              _startRecording();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9FE8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    // ✅ NEW: Prevent multiple starts
    if (_isRecording || _isAnalyzing || _isStopping) {
      print('⚠️ Recording already in progress or stopping');
      return;
    }

    try {
      // Check microphone permission
      bool hasPermission = await _permissionService.requestMicrophonePermission();
      if (!hasPermission) {
        if (mounted) {
          // ✅ NEW: Enhanced permission error dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.mic_off, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text('Izin Mikrofon Diperlukan', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: const Text(
                'VocaKey memerlukan akses ke mikrofon Anda untuk merekam suara. Silakan aktifkan izin di pengaturan aplikasi.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _startRecording(); // Retry after user grants permission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9FE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        final String filePath =
            '${appDocumentsDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: filePath,
        );

        _startNoiseMonitoring();

        setState(() {
          _isRecording = true;
          _isAnalyzing = false;
          _isStopping = false;
          _recordDuration = 0;
          _maxDecibel = 20;
          _amplitudes = List.filled(12, 0.2);
        });

        // ✅ Timer with auto-stop at 8 seconds
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            _recordDuration++;
          });

          // ✅ Auto-stop at maxRecordingDuration
          if (_recordDuration >= maxRecordingDuration) {
            print('⏰ Auto-stopping recording at $maxRecordingDuration seconds');
            timer.cancel();
            _stopRecording();
          }
        });
      } else {
        // ✅ NEW: Device/recorder not available error
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text('Perangkat Tidak Tersedia', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: const Text(
                'Mikrofon tidak terdeteksi pada perangkat Anda. Pastikan perangkat memiliki mikrofon yang berfungsi.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Go back to home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9FE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error starting recording: $e');
      if (mounted) {
        _showErrorDialog('Gagal memulai rekaman: $e');
      }
    }
  }

  void _startNoiseMonitoring() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading noiseReading) {
          if (!mounted) return;

          setState(() {
            _currentDecibel = noiseReading.meanDecibel;
            // ✅ NEW: Track maximum decibel for validation
            if (_currentDecibel > _maxDecibel) {
              _maxDecibel = _currentDecibel;
            }
            double normalizedDb = (_currentDecibel - 20).clamp(0, 70) / 70;

            // Shift amplitudes array
            for (int i = _amplitudes.length - 1; i > 0; i--) {
              _amplitudes[i] = _amplitudes[i - 1];
            }
            _amplitudes[0] = 0.2 + (normalizedDb * 0.8);
          });
        },
        onError: (error) {
          print('⚠️ Noise meter error: $error');
        },
      );
    } catch (e) {
      print('⚠️ Error starting noise monitoring: $e');
    }
  }

  /// ✅ NEW: Validates recording based on duration and volume levels
  /// 
  /// Returns:
  /// - Empty string if validation passes
  /// - Error message describing the validation failure
  /// 
  /// Checks:
  /// - Duration must be at least [minRecordingDuration] seconds
  /// - Maximum volume must exceed [minDecibelThreshold] dB
  String _validateRecording() {
    if (_recordDuration < minRecordingDuration) {
      return 'Rekaman terlalu pendek. Minimum $minRecordingDuration detik.';
    }

    if (_maxDecibel < minDecibelThreshold) {
      return 'Suara terlalu lemah. Harap berbicara atau bersenandung lebih keras.';
    }

    return ''; // Validation passed
  }

  /// ✅ NEW: Shows validation error dialog with retry option
  /// 
  /// Parameters:
  /// - [message] - Error message to display to user
  void _showValidationError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Rekaman Tidak Valid', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Kembali ke home
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetRecordingState();
              _startRecording();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9FE8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  /// ✅ NEW: Resets recording-related state variables to initial values
  /// 
  /// Used after recording failure or when retrying to ensure clean state
  void _resetRecordingState() {
    setState(() {
      _recordDuration = 0;
      _maxDecibel = 20;
      _amplitudes = List.filled(12, 0.2);
      _currentDecibel = 0;
      _isRecording = false;
      _isAnalyzing = false;
      _isStopping = false;
    });
  }

  Future<void> _stopRecording() async {
    // ✅ NEW: Debounce - prevent double stop
    if (_isStopping || !_isRecording) {
      print('⚠️ Stop already in progress or not recording');
      return;
    }

    setState(() {
      _isStopping = true;
    });

    try {
      _timer?.cancel();
      _noiseSubscription?.cancel();

      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isStopping = false;
      });

      if (path != null && mounted) {
        print('✅ Recording stopped: $path');
        print('   Duration: $_recordDuration seconds');
        print('   Max Decibel: $_maxDecibel dB');

        // ✅ NEW: Validate recording before processing
        final validationError = _validateRecording();
        if (validationError.isNotEmpty) {
          print('❌ Validation failed: $validationError');
          setState(() {
            _isAnalyzing = false;
            _amplitudes = List.filled(12, 0.2);
          });
          _showValidationError(validationError);
          return;
        }

        // Recording is valid - proceed to analysis
        setState(() {
          _isAnalyzing = true;
          _amplitudes = List.filled(12, 0.2);
        });

        // Simpan reference BLoC SEBELUM navigate
        final pitchBloc = context.read<PitchBloc>();

        // Navigate ke loading page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PitchLoadingPage(),
          ),
        );

        // Trigger analysis menggunakan reference
        Future.delayed(const Duration(milliseconds: 100), () {
          pitchBloc.add(AnalyzeAudioEvent(path));
        });
      } else {
        setState(() {
          _isAnalyzing = false;
        });
        if (mounted) {
          _showErrorDialog('Gagal menyimpan rekaman');
        }
      }
    } catch (e) {
      print('❌ Error stopping recording: $e');
      setState(() {
        _isAnalyzing = false;
        _isStopping = false;
      });
      if (mounted) {
        _showErrorDialog('Gagal menghentikan rekaman: $e');
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// ✅ NEW: Helper widget to display guide item with bullet point
  /// 
  /// Parameters:
  /// - [text] - Guide text to display
  Widget _buildGuideItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _recordDuration / maxRecordingDuration;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _isAnalyzing || _isRecording
                          ? null
                          : () {
                              // ✅ NEW: Ensure clean state before navigating back
                              _resetRecordingState();
                              Navigator.pop(context);
                            },
                      tooltip: 'Kembali',
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rekam Suara Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Title
              const Text(
                'Menentukan\nNada Dasar Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isAnalyzing
                    ? 'Menganalisis suara Anda...'
                    : _isRecording
                        ? 'Sedang merekam... (${maxRecordingDuration - _recordDuration}s)'
                        : 'Ketuk tombol untuk memulai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),

              const Spacer(flex: 1),

              // Audio Spectrum Visualizer
              if (_isRecording)
                _AudioSpectrumVisualizer(
                  amplitudes: _amplitudes,
                  isRecording: _isRecording,
                )
              else
                const SizedBox(height: 150),

              const Spacer(flex: 1),

              // Recording Button
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRecording)
                    CircularPercentIndicator(
                      radius: 90.0,
                      lineWidth: 8.0,
                      percent: progress.clamp(0.0, 1.0),
                      center: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          size: 70,
                          color: Colors.red,
                        ),
                      ),
                      progressColor: Colors.red,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  else
                    GestureDetector(
                      onTap: !_isAnalyzing && !_isStopping ? _startRecording : null,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _isAnalyzing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6B9FE8),
                                  strokeWidth: 4,
                                ),
                              )
                            : const Icon(
                                Icons.mic,
                                size: 70,
                                color: Color(0xFF6B9FE8),
                              ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Timer
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 48),

              const SizedBox(height: 20),

              // ✅ NEW: Recording instructions / humming guidance
              if (!_isRecording && !_isAnalyzing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Panduan Perekaman',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildGuideItem('Berbicara atau bersenandung dengan jelas'),
                        const SizedBox(height: 8),
                        _buildGuideItem('Suara harus terdengar jelas tanpa kebisingan latar'),
                        const SizedBox(height: 8),
                        _buildGuideItem('Minimal $minRecordingDuration detik, maksimal $maxRecordingDuration detik'),
                      ],
                    ),
                  ),
                )
              else if (_isRecording)
                const SizedBox(height: 0)
              else
                const SizedBox(height: 48),

              const SizedBox(height: 20),

              // Stop Button
              if (_isRecording)
                ElevatedButton.icon(
                  onPressed: _isStopping ? null : _stopRecording,
                  icon: const Icon(Icons.stop, size: 24),
                  label: Text(
                    _isStopping ? 'MENGHENTIKAN...' : 'HENTIKAN REKAMAN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStopping ? Colors.grey : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                )
              else if (!_isAnalyzing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Rekaman akan berhenti otomatis setelah $maxRecordingDuration detik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// Audio Spectrum Visualizer Widget
class _AudioSpectrumVisualizer extends StatelessWidget {
  final List<double> amplitudes;
  final bool isRecording;

  const _AudioSpectrumVisualizer({
    required this.amplitudes,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(12, (index) {
              final amplitude = amplitudes[index];
              final height = 20 + (amplitude * 70);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            }),
          ),
          Positioned(
            top: 5,
            right: 20,
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
