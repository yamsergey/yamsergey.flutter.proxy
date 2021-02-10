import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'proxy.dart';

class PlatformProxy {
  static const MethodChannel _channel = MethodChannel('platform_proxy');

  Future<List<Proxy>> getPlatformProxies({String url}) async {
    final String proxiesJson = await _channel.invokeMethod<dynamic>(
        'getPlatformProxy', <String, String>{'url': url}) as String;
    var jsonArray = jsonDecode(proxiesJson) as List<dynamic>;
    var proxies = jsonArray
        .map((e) => Proxy.fromJson(e as Map<String, dynamic>))
        .toList();
    return proxies;
  }
}
