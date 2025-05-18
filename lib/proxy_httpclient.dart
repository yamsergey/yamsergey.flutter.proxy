import 'dart:io';

import 'package:platform_proxy/platform_proxy.dart';

class ProxyAwareHttpClient implements HttpClient {
  final HttpClient _delegate;
  final PlatformProxy _platformProxy;
  final Map<String, String> _cache = {};

  ProxyAwareHttpClient(
      {required HttpClient client, required PlatformProxy platformProxy})
      : _delegate = client,
        _platformProxy = platformProxy {
    _delegate.findProxy = _findProxy as String Function(Uri)?;
  }

  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _delegate.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _delegate.addProxyCredentials(host, port, realm, credentials);

  @override
  void close({bool force = false}) => _delegate.close(force: force);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.delete(host, port, path);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.deleteUrl(url);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.get(host, port, path);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.getUrl(url);
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.head(host, port, path);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.headUrl(url);
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.open(method, host, port, path);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.openUrl(method, url);
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.patch(host, port, path);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.patchUrl(url);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.post(host, port, path);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.postUrl(url);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) async {
    await this.resolveProxies(Uri.parse(host));
    return await _delegate.put(host, port, path);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) async {
    await this.resolveProxies(url);
    return await _delegate.putUrl(url);
  }

  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _delegate.authenticate = f;

  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _delegate.authenticateProxy = f;

  @override
  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _delegate.badCertificateCallback = callback;

  @override
  set findProxy(String Function(Uri url)? f) => _delegate.findProxy = f;

  @override
  bool get autoUncompress => _delegate.autoUncompress;

  @override
  set autoUncompress(bool value) => _delegate.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _delegate.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) => _delegate.connectionTimeout = value;

  @override
  Duration get idleTimeout => _delegate.idleTimeout;

  @override
  set idleTimeout(Duration value) => _delegate.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _delegate.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _delegate.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _delegate.userAgent;

  @override
  set userAgent(String? value) => _delegate.userAgent = value;

  String _findProxy(Uri url) {
    var cacheValue = _cache[url.cacheKey];

    if (cacheValue == null) {
      // Naive assumption that it's a redirect of previous request which has to be routed through the same proxy
      _cache[url.cacheKey] = _cache.values.last;
      cacheValue = _cache[url.cacheKey];
    }

    if (cacheValue == null || cacheValue.isEmpty) {
      return HttpClient.findProxyFromEnvironment(url);
    }
    return cacheValue;
  }

  Future<void> resolveProxies(Uri url) async {
    if (_cache[url.cacheKey] != null) {
      return;
    } else {
      var proxies =
          await _platformProxy.getPlatformProxies(url: url.toString());
      _cache[url.cacheKey] = proxies.getProxiesAsPacWithCredentials();
      return;
    }
  }

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {
    _delegate.connectionFactory = f;
  }

  @override
  set keyLog(Function(String line)? callback) {
    _delegate.keyLog = callback;
  }
}

extension __UriToCacheKey on Uri {
  String get cacheKey => '${this.hasScheme}://${this.host}';
}
