# VocaKey - Pitch Detection App 🎵

VocaKey adalah aplikasi mobile Flutter yang menggunakan teknologi pitch detection untuk menganalisis nada dasar suara pengguna dan merekomendasikan lagu yang sesuai dengan vocal range mereka.

## 📋 Daftar Isi

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [API Integration](#api-integration)
- [Dependencies](#dependencies)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## ✨ Features

### Core Features
- 🎤 **Pitch Detection**: Deteksi nada dasar dari humming/bernyanyi user
- 🎵 **Song Recommendations**: Rekomendasi lagu berdasarkan vocal range yang terdeteksi
- 🎸 **Audio Playback**: Putar preview lagu dan dengarkan full track
- 📊 **Analysis Results**: Tampilkan hasil analisis dengan confidence score
- ❤️ **Favorites**: Simpan lagu favorit ke local storage

### UI/UX Features
- 🎨 **Modern Gradient Design**: Interface yang modern dan menarik
- 📱 **Responsive Design**: Bekerja optimal di berbagai ukuran device
- ⚡ **Smooth Animations**: Animasi yang smooth menggunakan Rive
- 🔄 **Real-time Feedback**: Feedback real-time saat recording

### Technical Features
- 🏗️ **Clean Architecture**: Implementasi Clean Architecture dengan BLoC pattern
- 🔐 **Error Handling**: Error handling yang comprehensive dan user-friendly
- 💾 **Local Storage**: Simpan history analisis dengan SharedPreferences
- 🌐 **API Integration**: Integrasi dengan backend API menggunakan Dio

## 📦 Requirements

### System Requirements
- **Flutter**: >= 3.0.0
- **Dart**: >= 3.0.0
- **Android**: Minimum SDK 21
- **iOS**: Minimum iOS 11.0

### Development Requirements
- Android Studio / Xcode
- Flutter SDK installed dan configured
- Git

### Device Requirements
- Microphone access
- Minimum 2GB RAM
- Android atau iOS device/emulator

## 🚀 Installation

### 1. Clone Repository

```bash
git clone https://github.com/alikmakanmie/Vocakey-FE.git
cd vocakey_fe
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Generate Code (BLoC + Models)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Fix Build Issues (jika ada)

```bash
# Clean build
flutter clean

# Rebuild
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## ⚙️ Setup

### 1. Configure API Base URL

Edit file `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api-url.com/';
  static const String analyzeEndpoint = 'api/analyze';
  static const String songsEndpoint = 'api/songs';
}
```

### 2. Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

Edit `android/app/src/main/AndroidManifest.xml` untuk menambahkan permissions:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. iOS Configuration

Edit `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_MICROPHONE=1',
      ]
    end
  end
end
```

Tambahkan ke `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Aplikasi memerlukan akses ke mikrofon untuk mendeteksi nada suara Anda</string>
<key>NSLocalNetworkUsageDescription</key>
<string>Aplikasi memerlukan akses ke jaringan lokal</string>
```

### 4. Initialize Dependency Injection

Dependency injection sudah dikonfigurasi di `lib/injection_container.dart`. File ini akan otomatis dijalankan saat app start.

## ▶️ Running the App

### Run di Android Emulator/Device

```bash
# List available devices
flutter devices

# Run di device tertentu
flutter run -d <device-id>

# Run dengan mode debug
flutter run

# Run dengan mode release
flutter run --release
```

### Run di iOS Simulator/Device

```bash
# Run di iOS simulator
flutter run -d all

# Run di iOS device (pastikan device sudah trusted)
flutter run -d <device-id>

# Run dengan mode release
flutter run -d <device-id> --release
```

### Build APK (Android)

```bash
# Build APK debug
flutter build apk

# Build APK release
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build IPA (iOS)

```bash
# Build IPA
flutter build ipa

# Output: build/ios/ipa/
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/           # Constants (API, Colors, etc)
│   ├── errors/              # Custom exceptions dan failures
│   ├── network/             # API client dan networking
│   ├── services/            # Core services (LocalStorage, Permission, etc)
│   ├── theme/               # App theme dan styling
│   └── presentation/        # Core widgets (MainLayout, etc)
│
├── features/
│   ├── splash/              # Splash screen
│   │   └── presentation/
│   │       └── pages/
│   │
│   ├── home/                # Home page
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── pitch/               # Pitch detection feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── song/                # Songs feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── music/               # Audio player
│       └── presentation/
│           ├── bloc/
│           └── pages/
│
├── injection_container.dart # Dependency injection setup
├── main.dart               # App entry point
└── README.md
```

## 🏗️ Architecture

Project menggunakan **Clean Architecture** dengan pola **BLoC** untuk state management:

### Layers

```
┌─────────────────────────────────────────┐
│        Presentation Layer (UI)           │
│  Pages → Widgets → BLoC → Events/States  │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│        Domain Layer (Business Logic)     │
│  Entities → Repositories → UseCases      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│        Data Layer (Data Sources)         │
│  Models → Repositories → DataSources     │
│  (API, Local Storage, Caching)           │
└─────────────────────────────────────────┘
```

### BLoC Pattern

Setiap feature memiliki BLoC untuk mengelola state:

- **Events**: Aksi yang user lakukan atau trigger dari sistem
- **States**: State yang diemit berdasarkan events
- **BLoC**: Logic untuk handle events dan emit states

Contoh Pitch Detection Flow:

```
User taps "Mulai Rekam"
    ↓
StartRecordingEvent
    ↓
PitchBloc._onStartRecording()
    ↓
Recording berlangsung...
    ↓
AnalyzeAudioEvent
    ↓
PitchAnalyzing (state) → Loading Page
    ↓
Analysis selesai
    ↓
PitchAnalysisSuccess (state) → Result Page
```

## 🌐 API Integration

### Base URL Configuration

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://api.vocakey.com/';
  static const String analyzeEndpoint = 'api/analyze';
}
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/analyze` | POST | Analyze audio dan detect pitch |
| `/api/songs` | GET | Get list semua lagu |
| `/api/songs/:id` | GET | Get detail lagu tertentu |
| `/api/songs/:id/lyrics` | GET | Get lirik lagu |

### Upload Audio

```dart
// Upload audio file
final response = await apiClient.uploadAudio(
  'api/analyze',
  audioFilePath,
);
```

### Error Handling

API errors ditangani dengan friendly messages:

- **422 Error**: Pitch tidak terdeteksi dengan jelas
- **400 Error**: Request parameter tidak valid
- **5xx Error**: Server error

## 📚 Dependencies

### State Management
- **flutter_bloc**: ^8.1.3 - BLoC pattern implementation

### Networking
- **dio**: ^5.4.0 - HTTP client
- **http**: ^1.1.0 - HTTP utilities

### Audio Processing
- **record**: ^5.1.2 - Audio recording
- **flutter_pitch_detection**: ^1.3.0 - Pitch detection
- **just_audio**: ^0.9.36 - Audio playback
- **audio_session**: ^0.1.16 - Audio session management
- **noise_meter**: ^5.0.1 - Real-time noise monitoring

### UI Components
- **flutter_screenutil**: ^5.9.0 - Responsive design
- **youtube_player_flutter**: ^9.0.3 - YouTube player
- **flutter_lyric**: ^3.0.2 - Lyric display
- **rive**: ^0.13.0 - Animations
- **percent_indicator**: ^4.2.3 - Progress indicators

### Utilities
- **get_it**: ^7.6.4 - Service locator
- **dartz**: ^0.10.1 - Functional programming
- **equatable**: ^2.0.5 - Equality helper
- **shared_preferences**: ^2.2.2 - Local storage
- **intl**: ^0.19.0 - Internationalization
- **permission_handler**: ^11.0.0 - Permission handling
- **url_launcher**: ^6.2.4 - URL launcher

## 🔧 Troubleshooting

### Issue: Microphone Permission Denied

**Solution:**
```bash
# Clear app data dan permissions
flutter clean

# Reinstall app
flutter pub get
flutter run

# Grant microphone permission saat prompt
```

### Issue: Audio Recording Not Working

**Solution:**
1. Check `AndroidManifest.xml` memiliki permission `RECORD_AUDIO`
2. Check `Info.plist` (iOS) memiliki microphone description
3. Restart app dan grant permission

### Issue: Build Errors dengan Dependencies

**Solution:**
```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Jika masih error, upgrade dependencies
flutter pub upgrade
```

### Issue: API Connection Error

**Solution:**
1. Verify API base URL di `api_constants.dart`
2. Check internet connection
3. Verify backend API sedang running
4. Check firewall/proxy settings

### Issue: Pitch Detection Returns Error 422

**Solution:**
1. Record dengan humming yang lebih jelas
2. Ensure audio quality bagus (minimal noise)
3. Record dalam environment yang tenang
4. Try dengan nada berbeda

## 🤝 Contributing

### Workflow

1. Create feature branch
   ```bash
   git checkout -b feature/feature-name
   ```

2. Make changes dan commit
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push ke GitHub
   ```bash
   git push origin feature/feature-name
   ```

4. Create Pull Request

### Code Style

- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use meaningful variable names
- Add comments untuk complex logic
- Format code dengan `flutter format .`

### Before Commit

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests (if any)
flutter test
```

## 📝 Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat: improve pitch detection error handling

- Add user-friendly error messages
- Better state management
- Improve UX with clear instructions

Fixes #123
```

## 📄 License

Project ini belum memiliki license. Hubungi author untuk informasi lebih lanjut.

## 👤 Author

**Alikmakanmie**
- GitHub: [@alikmakanmie](https://github.com/alikmakanmie)
- Email: zaelikha@gmail.com

## 🔗 Links

- 📱 Backend Repository: [Vocakey-BE](https://github.com/alikmakanmie/Vocakey_BE)
- 💻 Frontend Repository: [Vocakey-FE](https://github.com/alikmakanmie/Vocakey-FE)
- 📖 Flutter Documentation: [flutter.dev](https://flutter.dev)

## 📞 Support

Jika ada pertanyaan atau issue, silakan:
1. Create issue di GitHub
2. Kirim email ke zaelikha@gmail.com
3. Chat via GitHub discussions

---

**Terakhir diupdate**: February 3, 2026
**Current Version**: 2.0.0

Selamat mengembangkan! Happy coding! 🚀
