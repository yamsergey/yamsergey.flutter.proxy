package io.yamsergey.flutter.platform_proxy;

import java.net.Proxy;
import java.net.ProxySelector;
import java.net.URI;
import java.util.List;

public class ProxyResolver {

    List<Proxy> resolve(String url) {
        List<Proxy> proxies = ProxySelector.getDefault().select(URI.create(url));
        return  proxies;
    }
}
