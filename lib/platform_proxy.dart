import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'proxy.dart';

class PlatformProxy {
  static const MethodChannel _channel = MethodChannel('platform_proxy');

  Future<Iterable<Proxy>> getPlatformProxies({String url}) async {
    final String proxiesJson = await _channel.invokeMethod<dynamic>(
        'getPlatformProxy', <String, String>{'url': url}) as String;
    var jsonArray = jsonDecode(proxiesJson) as List<dynamic>;
    var proxies = jsonArray
        .map((e) => Proxy.fromJson(e as Map<String, dynamic>))
        .toSet()
        .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));
    return proxies;
  }
}

extension ProxiesAsPacString on Iterable<Proxy> {
  String getProxiesAsPac() {
    return this.map((e) => e.pacString).join('; ');
  }
}

class ProxyCredentials {
  final String host;
  final int port;
  final String realm;
  final HttpClientCredentials credentials;

  ProxyCredentials({this.host, this.port, this.realm, this.credentials});
}

extension ProxiesAsCredentials on Iterable<Proxy> {
  List<ProxyCredentials> get credentials {
    return this
        .where((e) => e.user.isNotEmpty && e.password.isNotEmpty)
        .map((e) => ProxyCredentials(
            host: e.host,
            port: int.parse(e.port),
            realm: '${e.type.toUpperCase()} PROXY ${e.host}:${e.port}',
            credentials: HttpClientBasicCredentials(e.user, e.password)))
        .toList();
  }
}
