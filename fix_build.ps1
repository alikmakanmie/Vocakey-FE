# fix_build.ps1
Write-Host "🔧 Fixing Build Errors..." -ForegroundColor Cyan

Write-Host "`n1. Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host "`n2. Removing pubspec.lock..." -ForegroundColor Yellow
if (Test-Path "pubspec.lock") {
    Remove-Item "pubspec.lock"
    Write-Host "✅ pubspec.lock removed" -ForegroundColor Green
}

Write-Host "`n3. Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n4. Upgrading packages..." -ForegroundColor Yellow
flutter pub upgrade

Write-Host "`n5. Building..." -ForegroundColor Yellow
flutter build apk --debug

Write-Host "`n✅ Fix complete!" -ForegroundColor Green
Write-Host "Run: flutter run -d emulator-5554" -ForegroundColor Cyan
