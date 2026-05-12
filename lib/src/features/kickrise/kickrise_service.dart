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

  static Future<bool> isDomesticDevice() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isDomesticDevice') ?? false;
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

  static Future<void> requestNotificationPermission() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('requestNotificationPermission');
  }

  /// Checks overlay → notification → China ROM battery/autostart → Samsung FSI
  /// in order and opens the first missing prompt. Returns true if a prompt was
  /// shown. Call again on the next app resume to advance to the next permission.
  static Future<bool> checkAndRequestNextPermission() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('checkAndRequestNextPermission') ?? false;
  }

  static Future<void> checkAndRequestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    final isDomestic = await isDomesticDevice();
    if (!isDomestic) return;
    final hasPermission = await checkOverlayPermission();
    if (hasPermission) return;
    await _channel.invokeMethod<String>('requestOverlayPermission');
  }
}
