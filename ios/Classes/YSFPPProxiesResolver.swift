// YSFPPProxiesResolver.swift
// Swift version of YSFPPProxiesResolver.h/.m for iOS
import Foundation

class YSFPPProxiesResolver {
    private(set) var proxies: [YSFPPProxy] = []
    
    @discardableResult
    func resolve(_ url: String) -> Bool {
        guard let targetUrl = URL(string: url) else { return false }
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else { return false }
        let proxiesUnmanaged = CFNetworkCopyProxiesForURL(targetUrl as CFURL, settings as CFDictionary)
        let proxiesArray = proxiesUnmanaged.takeRetainedValue() as NSArray
        let availableProxies: [[String: Any]] = proxiesArray.compactMap { ($0 as? NSDictionary) as? [String: Any] }
        guard !availableProxies.isEmpty else { return false }
        
        for proxyDict in availableProxies {
            if let typeString = proxyDict[kCFProxyTypeKey as String] as? String {
                switch typeString {
                case String(kCFProxyTypeHTTPS):
                    let server = settings["HTTPSProxy"] as? String
                    let port = "\(settings["HTTPSPort"] ?? "")"
                    let user = settings["HTTPSUser"] as? String
                    let password = user != nil ? resolveUserCredential(user: user!, server: server, port: port, isHttps: true) : nil
                    appendProxy(YSFPPProxy(host: server, port: port, user: user, password: password, type: .https))
                case String(kCFProxyTypeHTTP):
                    let server = settings["HTTPProxy"] as? String
                    let port = "\(settings["HTTPPort"] ?? "")"
                    let user = settings["HTTPUser"] as? String
                    let password = user != nil ? resolveUserCredential(user: user!, server: server, port: port, isHttps: false) : nil
                    appendProxy(YSFPPProxy(host: server, port: port, user: user, password: password, type: .http))
                case String(kCFProxyTypeNone):
                    appendProxy(YSFPPProxy(host: nil, port: nil, user: nil, password: nil, type: .none))
                default:
                    continue
                }
            }
        }
        return !proxies.isEmpty
    }
    
    private func resolveUserCredential(user: String, server: String?, port: String?, isHttps: Bool) -> String? {
        // For simplicity, this is a stub. Implement Keychain lookup if needed.
        return nil
    }
    
    func appendProxy(_ proxy: YSFPPProxy) {
        proxies.append(proxy)
    }
    
    func proxiesAsJson() -> String {
        let arr = proxies.map { $0.description }
        return "[" + arr.joined(separator: ",") + "]"
    }
}
