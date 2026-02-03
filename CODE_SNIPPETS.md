# VocaKey - Complete Code Snippets (Copy-Paste Ready)

## 🔧 All New Code Additions

### 1️⃣ STATE VARIABLES (RecordingPage.dart, lines ~26-44)

```dart
class _PitchRecordingPageState extends State<PitchRecordingPage>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final PermissionService _permissionService = PermissionService();

  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isStopping = false;
  bool _recordingFailed = false;           // ✅ NEW: Track recording failure
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;
  StreamSubscription<PitchState>? _blocSubscription;

  // Real-time audio amplitude
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  List<double> _amplitudes = List.filled(12, 0.2);
  double _currentDecibel = 0;
  double _maxDecibel = 20;                 // ✅ NEW: Track max volume

  // ✅ NEW: Auto-stop duration (8 seconds)
  static const int maxRecordingDuration = 8;
  // ✅ NEW: Minimum duration and volume thresholds
  static const int minRecordingDuration = 2;
  static const double minDecibelThreshold = 30.0;
```

---

### 2️⃣ VALIDATION FUNCTION (RecordingPage.dart)

```dart
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
```

---

### 3️⃣ VALIDATION ERROR DIALOG (RecordingPage.dart)

```dart
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
            Navigator.pop(context); // Back to home
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
```

---

### 4️⃣ STATE RESET FUNCTION (RecordingPage.dart)

```dart
/// ✅ NEW: Resets recording-related state variables to initial values
/// 
/// Used after recording failure or when retrying to ensure clean state
void _resetRecordingState() {
  setState(() {
    _recordDuration = 0;
    _maxDecibel = 20;
    _amplitudes = List.filled(12, 0.2);
    _currentDecibel = 0;
    _recordingFailed = false;
    _isRecording = false;
    _isAnalyzing = false;
    _isStopping = false;
  });
}
```

---

### 5️⃣ MODIFIED NOISE MONITORING (RecordingPage.dart)

```dart
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
```

---

### 6️⃣ ENHANCED PERMISSION DIALOG (RecordingPage.dart - _startRecording)

```dart
Future<void> _startRecording() async {
  if (_isRecording || _isAnalyzing || _isStopping) {
    print('⚠️ Recording already in progress or stopping');
    return;
  }

  try {
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
              'VocaKey memerlukan akses ke mikrofon Anda untuk merekam suara. '
              'Silakan aktifkan izin di pengaturan aplikasi.',
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
                  _startRecording(); // Retry after permission granted
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
              'Mikrofon tidak terdeteksi pada perangkat Anda. '
              'Pastikan perangkat memiliki mikrofon yang berfungsi.',
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
```

---

### 7️⃣ MODIFIED STOP RECORDING (RecordingPage.dart)

```dart
Future<void> _stopRecording() async {
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
      _audioPath = path;
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
          _recordingFailed = true;
          _isAnalyzing = false;
          _amplitudes = List.filled(12, 0.2);
        });
        _showValidationError(validationError);
        return;
      }

      // Recording is valid - proceed to analysis
      setState(() {
        _isAnalyzing = true;
        _recordingFailed = false;
        _amplitudes = List.filled(12, 0.2);
      });

      final pitchBloc = context.read<PitchBloc>();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PitchLoadingPage(),
        ),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        pitchBloc.add(AnalyzeAudioEvent(path));
      });
    } else {
      setState(() {
        _isAnalyzing = false;
        _recordingFailed = true;
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
      _recordingFailed = true;
    });
    if (mounted) {
      _showErrorDialog('Gagal menghentikan rekaman: $e');
    }
  }
}
```

---

### 8️⃣ GUIDE ITEM HELPER WIDGET (RecordingPage.dart)

```dart
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
```

---

### 9️⃣ PANDUAN WIDGET IN UI (RecordingPage.dart - build method)

```dart
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
```

---

### 🔟 MODIFIED HEADER (RecordingPage.dart)

```dart
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
```

---

### 1️⃣1️⃣ EMPTY STATE WITH RETRY (pitch_result_page.dart)

```dart
Widget _buildNoRecommendations() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(
          Icons.music_off,
          color: Colors.white.withOpacity(0.5),
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak Ada Rekomendasi',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Suara Anda tidak dapat dianalisis dengan jelas. Coba lagi dengan suara yang lebih jelas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        // ✅ NEW: Button to retry recording
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const PitchRecordingPage(),
              ),
              (Route<dynamic> route) => route.isFirst,
            );
          },
          icon: const Icon(Icons.mic, size: 20),
          label: const Text('Coba Rekam Lagi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B9FE8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

### 1️⃣2️⃣ ENHANCED HEADER (pitch_result_page.dart)

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // ✅ NEW: Navigate back to recording page (not home)
            Navigator.pop(context);
          },
          tooltip: 'Kembali',
        ),
        const SizedBox(width: 8),
        const Text(
          'Hasil Analisis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            // ✅ NEW: Navigate to home, clearing all navigation stack
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          tooltip: 'Ke Beranda',
        ),
      ],
    ),
  );
}
```

---

## ✨ Summary

- ✅ 12 code sections provided
- ✅ All copy-paste ready
- ✅ Includes new functions and modified methods
- ✅ UI widgets complete
- ✅ Error dialogs ready
- ✅ State management handled
- ✅ Navigation flow complete

**Total Lines of Code:** ~600 lines  
**Files Modified:** 2  
**Status:** Ready for implementation
