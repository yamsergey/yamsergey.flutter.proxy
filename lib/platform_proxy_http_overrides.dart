import 'dart:io';

import 'package:platform_proxy/platform_proxy.dart';

// ================================================================================================
// HAVE TO BE UPDATED IMMIDIATELY AFTER https://github.com/dart-lang/sdk/issues/44971 WILL BE SOLVED
// ================================================================================================

class PlatformProxyHttpOverrides extends HttpOverrides {
  final PlatformProxy platformProxy;

  PlatformProxyHttpOverrides(this.platformProxy);

  // @override
  Future<String> findProxyFromEnvironmentAsync(Uri url, Map<String, String> environment) async {
    var proxies = await platformProxy.getPlatformProxies(url: url.toString());
    if (proxies.isNotEmpty) {
      return proxies.getProxiesAsPac();
    } else {
      return super.findProxyFromEnvironment(url, environment);
    }
  }
}

