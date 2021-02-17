# platform_proxy

Flutter support only limited Proxy configuration out of the box. All that we can do it's provide system environment variables `http_proxy`, `https_proxy`, e.t.c [more details in documentation](https://api.dart.dev/stable/2.10.5/dart-io/HttpClient/findProxyFromEnvironment.html). If you won't define the variables, your http requests will bypass system proxy configuration.

This plugin is here to fix this.

## Proxy config matrix

Different OSes provide different options to configure proxy for user. Table below will try to represent the options. (Feel free to point out if something missed)

| OS | Manual | Manual + Credentials | Manual + Bypass | AutoProxy config (PAC) |
| ------ | ------ | ------ | ------ | ------ |
| Android | &check; | &cross; | &check; | &check; |
| iOS | &check; | &check; | &check; | &check; |
| Windows | &check; | &cross; | &check; | &check; |
| Mac OS | &check; | &check; | &check; | &check; |
| Linux | _in_progress_ | _in_progress_ | _in_progress_ | _in_progress_ |

## What platform_proxy plugin supports

Table below represent configuration options from _Proxy config matrix_ which suppurted by the plugin.

| OS | Manual | Manual + Credentials | Manual + Bypass | AutoProxy config (PAC) |
| ------ | ------ | ------ | ------ | ------ |
| Android | &check; | &cross; | &check; | &check; |
| iOS | &check; | &check; | &check; | &check; |
| Windows | &check; | &cross; | &check; | &check; |
| Mac OS | &check; | &check; | &check; | &check; |
| Linux | _in_progress_ | _in_progress_ | _in_progress_ | _in_progress_ |

## Getting Started

*Work is still in progress. There is an [issue in Dart SDK itself](https://github.com/dart-lang/sdk/issues/44971) which block easy integration of system proxy configuration.*

Instance of `PlatformProxy` class provides list of `Proxy` which enabled for provided `url`.
> Yes we have to request proxy configuration for every `URL` requested from our app, to get correct configuration. Even if a system has configuration for a proxy it doesn't mean that the proxy is enabled for the URL (e.g. bypass option and PAC)

Then the proxy configuration have to be provided with [`findProxy`](https://api.dart.dev/stable/2.10.5/dart-io/HttpClient/findProxyFromEnvironment.html) method. The method support extended `PAC` string (original one doesn't support credentials). To simplify this the plugin has extension to convert `Iterable<Proxy>` to PAC string with or without credentials:

```
var platformProxy = PlatformProxy();
var proxies = await _platformProxy.getPlatformProxies(url: "your url");
var pacString = proxies.getProxiesAsPac();
or
var pacString = proxies.pacStringWithCredentials();           
```

Unfortunately `findProxy` method is synchronous and we are not allowed to use `await` there. Before that problem is fixed you can try to use `ProxyAwareHttpClient` for `dart.io` `HttpClient` which prefetch proxy configuration before make real request.

```
 final client = ProxyAwareHttpClient(client: HttpClient(), platformProxy: PlatformProxy());
 client.getUrl(Uri.parse('https://flutter.dev')).then((value) => value.close()).then((value) {});
```
