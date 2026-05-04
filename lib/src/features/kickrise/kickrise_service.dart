import 'dart:io';

import 'package:flutter/services.dart';

class KickriseService {
  static const _channel = MethodChannel('kickrise/popup');

  static Future<bool> checkOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('checkOverlayPermission') ?? false;
  }

  static Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  static Future<bool> isXiaomiDevice() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isXiaomiDevice') ?? false;
  }

  static Future<bool> checkBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('checkBatteryOptimization') ?? true;
  }

  static Future<void> requestBatteryOptimization() async {
    await _channel.invokeMethod('requestBatteryOptimization');
  }

  static Future<bool> requestMiuiAutostart() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestMiuiAutostart') ?? false;
  }

  static Future<void> checkAndRequestMiuiPermissions() async {
    if (!Platform.isAndroid) return;
    final isXiaomi = await isXiaomiDevice();
    if (!isXiaomi) return;
    final batteryOk = await checkBatteryOptimization();
    if (!batteryOk) requestBatteryOptimization();
  }

  static Future<void> checkAndRequestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    final isXiaomi = await isXiaomiDevice();
    if (!isXiaomi) return;
    final hasPermission = await checkOverlayPermission();
    if (!hasPermission) requestOverlayPermission();
  }
}
