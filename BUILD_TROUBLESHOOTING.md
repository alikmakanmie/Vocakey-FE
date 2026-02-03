# Build Troubleshooting Guide

## Error: "ResetPitchEvent isn't defined"

### Penyebab
Error ini terjadi ketika Flutter compiler tidak menemukan `ResetPitchEvent` class yang seharusnya ter-import dari file `pitch_event.dart`.

Biasanya penyebab:
1. **Cache build yang lama** - Build cache tidak ter-update dengan file terbaru
2. **IDE cache** - IDE (Android Studio/VS Code) belum me-reload file
3. **Pubspec dependency tidak ter-resolve** - Dependency tree tidak consistent

### Solusi

#### Solusi 1: Clean Build (Recommended) ✅

```bash
# 1. Clean everything
flutter clean

# 2. Get dependencies fresh
flutter pub get

# 3. Run again
flutter run
```

#### Solusi 2: Clean Cache Gradle (Android)

```bash
# Windows PowerShell / Command Prompt
cd android
./gradlew clean
cd ..
flutter run

# Linux / macOS
cd android
./gradlew clean
cd ..
flutter run
```

#### Solusi 3: Clear IDE Cache

**Android Studio:**
1. File → Invalidate Caches / Restart
2. Select "Invalidate and Restart"
3. Wait for Android Studio restart
4. Run flutter clean & flutter run

**VS Code:**
1. Reload VS Code window (Ctrl+Shift+P → "Reload Window")
2. Or close and reopen VS Code
3. Run flutter clean & flutter run

#### Solusi 4: Force Rebuild Without Cache

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean
flutter run
```

### Verifikasi File Sudah Benar

Pastikan file `lib/features/pitch/presentation/pages/pitch_recording_page.dart` memiliki import ini:

```dart
import '../bloc/pitch_event.dart';  // ← This line MUST exist!
```

Dan file `lib/features/pitch/presentation/bloc/pitch_event.dart` memiliki class ini:

```dart
class ResetPitchEvent extends PitchEvent {}
```

### Jika Error Masih Terjadi

1. **Check file actually exists**
   ```bash
   # Verify file ada
   cat lib/features/pitch/presentation/bloc/pitch_event.dart | grep ResetPitchEvent
   
   # Should output:
   # class ResetPitchEvent extends PitchEvent {}
   ```

2. **Analyze kode**
   ```bash
   flutter analyze lib/features/pitch/
   ```

3. **Check line number di error**
   - Error menunjuk ke line 120 dan 129
   - Pastikan itu benar file `pitch_recording_page.dart`

4. **Update Flutter SDK**
   ```bash
   flutter upgrade
   ```

5. **Reset project completely**
   ```bash
   flutter clean
   rm -rf pubspec.lock
   flutter pub get
   flutter run
   ```

## Error: "Gradle task assembleDebug failed"

### Penyebab
Masalah saat build Android. Bisa karena berbagai faktor.

### Solusi

1. **Check Java installation**
   ```bash
   java -version
   # Should show Java version
   ```

2. **Set JAVA_HOME (jika diperlukan)**
   
   **Windows:**
   ```powershell
   # Set temporarily
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-11"
   flutter run
   ```
   
   **Linux/macOS:**
   ```bash
   export JAVA_HOME=/usr/libexec/java_home
   flutter run
   ```

3. **Clean Gradle cache**
   ```bash
   flutter clean
   cd android && ./gradlew clean && cd ..
   flutter pub get
   flutter run --verbose
   ```

4. **Check Android SDK**
   ```bash
   flutter doctor
   ```

## Error: "Execution failed for task ':app:compileFlutterBuildDebug'"

### Penyebab
Flutter Dart compilation error (seperti missing import).

### Solusi

1. **Check error message carefully** - Error messages biasanya menunjuk ke line dan file yang bermasalah

2. **Verify imports**
   - Pastikan semua class yang digunakan sudah di-import
   - Check typo di import statement

3. **Run dengan verbose**
   ```bash
   flutter run --verbose 2>&1 | tee build.log
   # Check build.log untuk full error message
   ```

4. **Run pub get lagi**
   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Error: "No connected devices"

### Penyebab
Tidak ada emulator/device yang terhubung ke Flutter.

### Solusi

1. **List devices**
   ```bash
   flutter devices
   ```

2. **Start emulator**
   ```bash
   # List available emulators
   flutter emulators
   
   # Start specific emulator
   flutter emulators --launch <emulator_id>
   
   # Contoh:
   flutter emulators --launch Pixel_API_33
   ```

3. **Connect physical device**
   - Enable USB Debugging di device
   - Connect via USB
   - Verify dengan `flutter devices`

4. **Run dengan device tertentu**
   ```bash
   flutter run -d <device-id>
   ```

## Checklist untuk Memastikan Setup Benar

```
✅ Flutter SDK installed (flutter --version)
✅ Dart SDK installed (dart --version)
✅ Android SDK installed (flutter doctor)
✅ Java installed (java -version)
✅ JAVA_HOME set correctly (echo $JAVA_HOME)
✅ All pub dependencies gotten (flutter pub get)
✅ Build tools up to date (flutter upgrade)
✅ Project tidak ada compile errors (flutter analyze)
✅ Device/emulator connected (flutter devices)
✅ No conflicting dependencies (cat pubspec.lock | grep record_linux)
```

## Quick Fix Commands

Jika stuck, coba commands ini secara berurutan:

```bash
# 1. Clean everything
flutter clean

# 2. Remove lock file
rm pubspec.lock

# 3. Get fresh dependencies
flutter pub get

# 4. Build runner (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Analyze for errors
flutter analyze

# 6. Run
flutter run -v
```

## Debugging Tips

### Print Flutter doctor info
```bash
flutter doctor -v
```

### Check pubspec.lock for conflicts
```bash
cat pubspec.lock | grep -A5 -B5 "record"
```

### View app logs
```bash
flutter logs
```

### Kill all Flutter processes
```bash
# Windows
taskkill /F /IM flutter.bat

# Linux/macOS
pkill -9 flutter
```

---

Jika masalah persisten, coba:
1. Update Flutter: `flutter upgrade`
2. Clear pub cache: `flutter pub cache clean`
3. Check GitHub issues: https://github.com/flutter/flutter/issues
4. Ask di Flutter community: https://flutter.dev/community
