import 'dart:io';

import 'package:platform_proxy/platform_proxy.dart';

// ================================================================================================
// HAVE TO BE UPDATED IMMIDIATELY AFTER https://github.com/dart-lang/sdk/issues/44971 WILL BE SOLVED
// ================================================================================================

class PlatformProxyHttpOverrides extends HttpOverrides {
  final PlatformProxy platformProxy;

  PlatformProxyHttpOverrides(this.platformProxy);

  // @override
  // String findProxyFromEnvironment(Uri url, Map<String, String> environment) {
  //   var proxies =
  //       waitFor(platformProxy.getPlatformProxies(url: url.toString()));
  //   if (proxies.isNotEmpty) {
  //     return proxies.getProxiesAsPac();
  //   } else {
  //     return super.findProxyFromEnvironment(url, environment);
  //   }
  // }
}

class ProxyAwareHttpClient {
  final HttpClient _httpClient;
  final PlatformProxy _platformProxy;
  final Map<String, String> _cache = {};

  ProxyAwareHttpClient({HttpClient client, PlatformProxy platformProxy})
      : _httpClient = client,
        _platformProxy = platformProxy {
    _httpClient.findProxy = _findProxy;
  }

  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _httpClient.addCredentials(url, realm, credentials);

  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _httpClient.addProxyCredentials(host, port, realm, credentials);

  void close({bool force = false}) => _httpClient.close(force: force);

  Future<HttpClientRequest> delete(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.delete(host, port, path);
  }

  Future<HttpClientRequest> deleteUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.deleteUrl(url);
  }

  Future<HttpClientRequest> get(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.get(host, port, path);
  }

  Future<HttpClientRequest> getUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.getUrl(url);
  }

  Future<HttpClientRequest> head(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.head(host, port, path);
  }

  Future<HttpClientRequest> headUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.headUrl(url);
  }

  Future<HttpClientRequest> open(
      String method, String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.open(method, host, port, path);
  }

  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.openUrl(method, url);
  }

  Future<HttpClientRequest> patch(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.patch(host, port, path);
  }

  Future<HttpClientRequest> patchUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.patchUrl(url);
  }

  Future<HttpClientRequest> post(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.post(host, port, path);
  }

  Future<HttpClientRequest> postUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.postUrl(url);
  }

  Future<HttpClientRequest> put(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _httpClient.put(host, port, path);
  }

  Future<HttpClientRequest> putUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _httpClient.putUrl(url);
  }

  String _findProxy(Uri url) {
    print("FIND PROXY $url ${_cache[url.cacheKey]}");
    return _cache[url.cacheKey];
  }

  Future<void> resolveProxies(Uri url) async {
    if (_cache[url.cacheKey] != null) {
      return;
    } else {
      var proxies =
          await _platformProxy.getPlatformProxies(url: url.toString());
      _cache[url.cacheKey] = proxies.getProxiesAsPac();
      return;
    }
  }

  set authenticate(
          Future<bool> Function(Uri url, String scheme, String realm) f) =>
      _httpClient.authenticate = f;

  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String realm)
              f) =>
      _httpClient.authenticateProxy = f;

  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)
              callback) =>
      _httpClient.badCertificateCallback = callback;

  set findProxy(String Function(Uri url) f) => _httpClient.findProxy = f;
}

extension __UriToCacheKey on Uri {
  String get cacheKey => '${this.hasScheme}://${this.host}';
}
