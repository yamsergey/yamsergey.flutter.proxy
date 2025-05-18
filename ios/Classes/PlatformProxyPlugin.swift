// PlatformProxyPlugin.swift
// Swift version of PlatformProxyPlugin for iOS
import Flutter
import UIKit

public class PlatformProxyPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "platform_proxy", binaryMessenger: registrar.messenger())
        let instance = PlatformProxyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformProxy":
            if let args = call.arguments as? [String: String], let url = args["url"] {
                let resolver = YSFPPProxiesResolver()
                resolver.resolve(url)
                result(resolver.proxiesAsJson())
            } else {
                result("[]")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
