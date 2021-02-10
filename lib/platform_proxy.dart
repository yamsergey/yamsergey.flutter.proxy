import 'dart:async';

import 'package:flutter/services.dart';

class PlatformProxy {
  static const MethodChannel _channel = MethodChannel('platform_proxy');

  Future<String> getPlatformProxy({String url}) async {
    final String version = await _channel.invokeMethod<dynamic>(
        'getPlatformProxy', <String, String>{'url': url}) as String;
    return version;
  }
}

