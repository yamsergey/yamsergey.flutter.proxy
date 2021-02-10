package io.yamsergey.flutter.platform_proxy;

import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URI;
import java.util.Iterator;
import java.util.List;

public class ProxyStringifier {

    private final List<Proxy> proxies;

    public ProxyStringifier(List<Proxy> proxies) {
        this.proxies = proxies;
    }

    String stringify(URI url) {
        StringBuilder builder = new StringBuilder();
        builder.append("[");

        Iterator<Proxy> iterator = proxies.iterator();

        while (iterator.hasNext()) {
            Proxy proxy = iterator.next();
            if (proxy.type() == Proxy.Type.DIRECT) {
                builder.append("{\"host\":\"\", \"port\":\"\",\"type\":\"none\",\"user\":\"\",\"password\":\"\"}");
            } else if (proxy.type() == Proxy.Type.HTTP && proxy.address() instanceof InetSocketAddress) {
                InetSocketAddress address = (InetSocketAddress) proxy.address();
                if ("http".equals(url.getScheme())) {
                    builder.append(String.format("{\"host\":\"%s\", \"port\":\"%s\",\"type\":\"http\",\"user\":\"\",\"password\":\"\"}", address.getHostName(), address.getPort()));
                } else if ("https".equals(url.getScheme())) {
                    builder.append(String.format("{\"host\":\"%s\", \"port\":\"%s\",\"type\":\"https\",\"user\":\"\",\"password\":\"\"}", address.getHostName(), address.getPort()));
                }
            }
            if (iterator.hasNext()) {
                builder.append(",");
            }
        }

        builder.append("]");

        return builder.toString();
    }
}
