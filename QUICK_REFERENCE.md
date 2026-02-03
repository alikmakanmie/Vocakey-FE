# VocaKey - Code Snippets & Quick Reference

## 🔧 Quick Implementation Reference

### Jika perlu menambah threshold validasi, ubah constants ini:

**File:** `lib/features/pitch/presentation/pages/pitch_recording_page.dart`

```dart
// Durasi minimum rekaman (dalam detik)
static const int minRecordingDuration = 2;

// Durasi maksimum rekaman (dalam detik) 
static const int maxRecordingDuration = 8;

// Threshold volume minimum (dalam dB)
static const double minDecibelThreshold = 30.0;
```

---

## 📍 Key Functions Locations

### RecordingPage.dart State Variables
```dart
// Lines ~26-44: State variables
bool _recordingFailed = false;           // NEW: Track if recording failed
int _recordDuration = 0;
Timer? _timer;
double _maxDecibel = 20;                 // NEW: Track max decibel for validation
List<double> _amplitudes = List.filled(12, 0.2);
```

### New Methods Added to RecordingPage
```dart
// Lines ~254-265: _validateRecording()
// Validates recording based on duration and volume

// Lines ~267-305: _showValidationError()
// Shows error dialog with retry option

// Lines ~307-324: _resetRecordingState()
// Cleans up all recording state variables

// Lines ~432-456: _buildGuideItem()
// Helper widget for recording guidelines

// Lines ~139-170: _startNoiseMonitoring() [MODIFIED]
// Now tracks maximum decibel
```

---

## 🎯 Common Customization Scenarios

### Scenario 1: Ubah Durasi Maksimum Rekaman
```dart
// Dari 8 detik menjadi 10 detik
static const int maxRecordingDuration = 10;  // Change this

// Timer akan otomatis menyesuaikan
```

### Scenario 2: Ubah Threshold Volume
```dart
// Saat ini 30 dB, buat lebih sensitif (lebih rendah)
static const double minDecibelThreshold = 25.0;  // Lebih sensitif
// atau
static const double minDecibelThreshold = 35.0;  // Lebih ketat
```

### Scenario 3: Ubah Pesan Error
**File:** `pitch_recording_page.dart` - `_validateRecording()` method

```dart
String _validateRecording() {
  if (_recordDuration < minRecordingDuration) {
    // Ubah pesan ini:
    return 'Rekaman terlalu pendek. Minimum $minRecordingDuration detik.';
  }

  if (_maxDecibel < minDecibelThreshold) {
    // atau pesan ini:
    return 'Suara terlalu lemah. Harap berbicara atau bersenandung lebih keras.';
  }

  return '';
}
```

### Scenario 4: Ubah Styling Panduan Widget
**File:** `pitch_recording_page.dart` - Lines ~550-575

```dart
Container(
  padding: const EdgeInsets.all(16),  // Ubah padding
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),  // Ubah opacity
    borderRadius: BorderRadius.circular(12),  // Ubah radius
    border: Border.all(
      color: Colors.white.withOpacity(0.3),  // Ubah border color
      width: 1,
    ),
  ),
  // ... rest
)
```

---

## 🔄 Navigation Flow

```
HomePage
  ↓
PitchRecordingPage
  ↓ (Recording Success)
PitchLoadingPage
  ↓ (Analysis Complete)
PitchResultPage
  ↓ (Back Button)
PitchRecordingPage (Returns here)
  ↓ (Home Button)
HomePage
```

**Special Cases:**
- Recording Failed → Dialog "Ulang Rekam" → PitchRecordingPage
- No Recommendations → "Coba Rekam Lagi" Button → PitchRecordingPage
- Permission Denied → Dialog Retry → _startRecording() again
- Device Not Found → Dialog → Navigate back to HomePage

---

## 📊 State Diagram

```
Initial State
  ├─ _isRecording = false
  ├─ _isAnalyzing = false
  ├─ _isStopping = false
  ├─ _recordingFailed = false
  └─ _recordDuration = 0

↓ User taps Mic Button

Recording State
  ├─ _isRecording = true
  ├─ Timer active (1 second interval)
  ├─ Noise monitoring active
  └─ _recordDuration incrementing

↓ User taps Stop OR Timer reaches 8 seconds

Stopping State
  ├─ _isStopping = true
  ├─ Timer cancelled
  ├─ Noise subscription cancelled
  └─ Recording file saved

↓ Validation Check

├─ If Valid → Analyzing State
│   ├─ _isAnalyzing = true
│   ├─ Navigate to LoadingPage
│   └─ Trigger audio analysis
│
└─ If Invalid → Failed State
    ├─ _recordingFailed = true
    ├─ Show error dialog
    └─ User can retry

↓ After Dialog Action

├─ Retry → Call _resetRecordingState() → Back to Initial State
└─ Cancel → Navigate back to HomePage → Initial State
```

---

## 🐛 Debugging Tips

### Untuk melihat log recording:
```
Look for console prints:
✅ Recording stopped: /path/to/file
   Duration: 5 seconds
   Max Decibel: 65 dB
```

### Untuk debug validation:
```
❌ Validation failed: Suara terlalu lemah. Harap berbicara atau bersenandung lebih keras.
```

### Untuk debug noise meter:
```
⚠️ Noise meter error: ...
⚠️ Error starting noise monitoring: ...
```

### Enable detailed logging:
Tambahkan di _startNoiseMonitoring() untuk track setiap reading:
```dart
print('🔊 Current dB: $_currentDecibel | Max: $_maxDecibel');
```

---

## ⚡ Performance Optimizations

1. **Prevent Double-Stop:**
   ```dart
   if (_isStopping || !_isRecording) {
     print('⚠️ Stop already in progress or not recording');
     return;
   }
   ```

2. **State Reset on Back Button:**
   ```dart
   onPressed: () {
     _resetRecordingState();  // Clean up before nav
     Navigator.pop(context);
   }
   ```

3. **Amplitude Visualization Shift:**
   ```dart
   for (int i = _amplitudes.length - 1; i > 0; i--) {
     _amplitudes[i] = _amplitudes[i - 1];  // Shift array
   }
   _amplitudes[0] = 0.2 + (normalizedDb * 0.8);  // Add new value
   ```

---

## 📱 Testing Scenarios

### Test 1: Normal Happy Path
1. Tap Mic Button
2. Humming for 3 seconds
3. Tap Stop
4. ✅ Should proceed to LoadingPage

### Test 2: Recording Too Short
1. Tap Mic Button
2. Humming for 1 second
3. Tap Stop
4. ✅ Should show "Rekaman terlalu pendek" dialog
5. Tap "Coba Lagi" → Back to recording

### Test 3: Recording Too Quiet
1. Tap Mic Button
2. Very quiet humming for 3 seconds
3. Tap Stop
4. ✅ Should show "Suara terlalu lemah" dialog

### Test 4: Auto Stop at 8 Seconds
1. Tap Mic Button
2. Let it record for 8+ seconds
3. ✅ Should auto-stop without tapping Stop button

### Test 5: Permission Denied
1. Deny microphone permission in OS settings
2. Tap Mic Button
3. ✅ Should show permission dialog
4. Tap "Coba Lagi" with permission granted

### Test 6: Navigation Back
1. In RecordingPage, tap back arrow
2. ✅ Should reset state and go back to HomePage
3. Verify no lingering audio files or timers

---

## 🎯 File Modification Summary

### pitch_recording_page.dart
- **Added:** 4 new state variables
- **Added:** 3 new methods (_validateRecording, _showValidationError, _resetRecordingState, _buildGuideItem)
- **Modified:** _startNoiseMonitoring() - track max decibel
- **Modified:** _stopRecording() - add validation logic
- **Modified:** _startRecording() - enhanced error dialogs
- **Modified:** build() - add panduan widget
- **Modified:** Header - add tooltip dan state cleanup

### pitch_result_page.dart
- **Modified:** _buildNoRecommendations() - add retry button
- **Modified:** _buildHeader() - add tooltips
- **Total Lines Changed:** ~30 lines

---

## 💡 Pro Tips

1. **Max Decibel Reset:**
   Always reset `_maxDecibel = 20` when starting new recording

2. **State Cleanup:**
   Always call `_resetRecordingState()` before navigating away

3. **Timer Safety:**
   Always check `if (!mounted)` inside Timer callbacks

4. **Error Messages:**
   Keep messages user-friendly dan dalam Bahasa Indonesia

5. **Accessibility:**
   Add `tooltip` ke semua icon buttons untuk clarity

---

## 📞 Support Notes

- All new functions have JSDoc-style documentation
- Error messages are clear dan actionable
- User can always retry atau cancel tanpa being stuck
- No memory leaks (timers cancelled, subscriptions disposed)
- Robust against rapid taps atau edge cases

---

**Last Updated:** 01 February 2026  
**Version:** 1.0 - Production Ready
