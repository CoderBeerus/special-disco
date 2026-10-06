import 'package:flutter/services.dart';

class DisplayModeChannel {
  static const MethodChannel _channel = MethodChannel('aniweb/display_mode');

  static Future<double?> getPreferredRefreshRate() async {
    final value = await _channel.invokeMethod<double>('getPreferredRefreshRate');
    return value;
  }

  static Future<void> requestHighRefreshIfSupported() async {
    await _channel.invokeMethod<void>('requestHighRefreshIfSupported');
  }
}
