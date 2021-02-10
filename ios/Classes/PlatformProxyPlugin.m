#import "PlatformProxyPlugin.h"

@implementation PlatformProxyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"platform_proxy"
                                     binaryMessenger:[registrar messenger]];
    PlatformProxyPlugin* instance = [[PlatformProxyPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformProxy" isEqualToString:call.method]) {
        NSString *targetUrl = [call arguments][@"url"];
        if (targetUrl) {
            YSFPPProxiesResolver *resolver = [[YSFPPProxiesResolver alloc] init];
            [resolver resolve:targetUrl];
            result([resolver proxiesAsJson]);
        } else {
            result(@"[]");
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
