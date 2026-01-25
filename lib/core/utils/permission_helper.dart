import 'package:permission_handler/permission_handler.dart';
import '../constants/app_strings.dart';

class PermissionHelper {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
