import Cocoa
import FlutterMacOS

public class PlatformProxyPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "platform_proxy", binaryMessenger: registrar.messenger)
        let instance = PlatformProxyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformProxy":
            if let targetUrl = (call.arguments as? [String:String])?["url"] {
                let resolver = YSFPPProxiesResolver()
                
                if (resolver.resolve(targetUrl)) {
                    result("\(resolver.proxies)")
                } else {
                    result("")
                }
            } else {
                result("")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
