import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

const micPermissionError = 'mic_permission';

enum CallAudioPermission { granted, denied, permanentlyDenied }

Future<CallAudioPermission> ensureCallAudioPermission() async {
  var mic = await Permission.microphone.status;
  if (mic.isDenied || mic.isRestricted) {
    mic = await Permission.microphone.request();
  }
  if (mic.isPermanentlyDenied || mic.isRestricted) {
    return CallAudioPermission.permanentlyDenied;
  }
  if (!mic.isGranted) {
    return CallAudioPermission.denied;
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    final bluetooth = await Permission.bluetoothConnect.status;
    if (bluetooth.isDenied) {
      await Permission.bluetoothConnect.request();
    }
  }
  return CallAudioPermission.granted;
}
