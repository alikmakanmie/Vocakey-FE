import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    
    if (status.isGranted) {
      print('Microphone permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      print('Permission permanently denied, opening settings');
      await openAppSettings();
      return false;
    } else {
      print('Microphone permission denied');
      return false;
    }
  }

  /// Check if microphone permission is already granted
  Future<bool> hasMicrophonePermission() async {
    var status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request storage permission (if needed for saving audio files)
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }
}
