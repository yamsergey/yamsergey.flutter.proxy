#import "YSFPPProxiesResolver.h"

@implementation YSFPPProxiesResolver

static void ResultCallback(void* client, CFArrayRef proxies, CFErrorRef error)
{
    YSFPPProxiesResolver *myself = (__bridge YSFPPProxiesResolver*) client;
    NSArray *proxiesList  = (__bridge NSArray*) proxies;
    
    for (NSDictionary *dictionary in proxiesList) {
        NSString *typeString = dictionary[(__bridge NSString*) kCFProxyTypeKey];
        NSString *hostString = dictionary[(__bridge NSString*) kCFProxyHostNameKey];
        NSString *portString = dictionary[(__bridge NSString*) kCFProxyPortNumberKey];
        
        if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeHTTPS]) {
            [myself appendProxy:[[YSFPPProxy alloc] initWithHost:hostString port:portString user:nil password:nil type: ySFPPHTTPS]];
        } else if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeHTTP]) {
            [myself appendProxy:[[YSFPPProxy alloc] initWithHost:hostString port:portString user:nil password:nil type: ySFPPHTTP]];
        } else if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeNone]) {
            [myself appendProxy:[[YSFPPProxy alloc] initWithHost:hostString port:portString user:nil password:nil type: ySFPPNONE]];
        }
    }
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _proxies = [NSMutableArray new];
    }
    return self;
}

- (BOOL)resolve:(NSString *)url {
    NSURL *targetUrl = [NSURL URLWithString:url];
    
    CFDictionaryRef settings = CFNetworkCopySystemProxySettings();
    NSArray *availableProxies = (__bridge NSArray*) CFNetworkCopyProxiesForURL((__bridge CFURLRef) targetUrl, settings);
    
    for (NSDictionary *proxyDict in availableProxies) {
        NSString *typeString = proxyDict[(__bridge NSString*) kCFProxyTypeKey];
        if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeAutoConfigurationURL]) {
            NSURL *autoUrl = proxyDict[(__bridge NSURL*) kCFProxyAutoConfigurationURLKey];
            [self resolveAutoProxyUrl:autoUrl targetURL:targetUrl];
        } else if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeAutoConfigurationJavaScript]) {
            NSString *autoJavaScript = proxyDict[(__bridge NSString*) kCFProxyAutoConfigurationJavaScriptKey];
            [self resolveAutoProxyScript:autoJavaScript targetURL:targetUrl];
        } else if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeHTTPS]) {
            NSDictionary *settingsDict = (__bridge NSDictionary*) settings;
            NSString *user = settingsDict[@"HTTPSUser"];
            NSString *server = settingsDict[@"HTTPSProxy"];
            NSString *port = [NSString stringWithFormat:@"%@", settingsDict[@"HTTPSPort"]];
            
            if (user) {
                NSString *password = [self resolveUserCredential:user withServer:server withPort:port withHttps:true];
                [self appendProxy:[[YSFPPProxy alloc] initWithHost:server port:port user:user password:password type:ySFPPHTTPS]];
            } else {
                [self appendProxy:[[YSFPPProxy alloc] initWithHost:server port:port user:nil password:nil type:ySFPPHTTPS]];
            }
        } else if ([typeString isEqualToString:(__bridge NSString*) kCFProxyTypeHTTP]) {
            NSDictionary *settingsDict = (__bridge NSDictionary*) settings;
            NSString *user = settingsDict[@"HTTPUser"];
            NSString *server = settingsDict[@"HTTPProxy"];
            NSString *port = [NSString stringWithFormat:@"%@", settingsDict[@"HTTPPort"]];
            
            if (user) {
                [self resolveUserCredential:user withServer:server withPort:port withHttps:false];
                NSString *password = [self resolveUserCredential:user withServer:server withPort:port withHttps:true];
                [self appendProxy:[[YSFPPProxy alloc] initWithHost:server port:port user:user password:password type:ySFPPHTTP]];
            } else {
                [self appendProxy:[[YSFPPProxy alloc] initWithHost:server port:port user:nil password:nil type:ySFPPHTTP]];
            }
        }
    }
    return [self.proxies count] > 0;
}

- (nullable NSString*) resolveUserCredential:(NSString*)user withServer:(NSString*)server withPort:(NSString*)port withHttps:(BOOL)isHttps {
    NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject: (id)kSecClassInternetPassword  forKey:(id)kSecClass];
    [query setObject: server  forKey:(id)kSecAttrServer];
    [query setObject: (isHttps) ? (id) kCFBooleanTrue : (id) kCFBooleanFalse   forKey:(id)kSecAttrProtocolHTTPS];
    [query setObject: (!isHttps) ? (id) kCFBooleanTrue : (id) kCFBooleanFalse  forKey:(id)kSecAttrProtocolHTTP];
    [query setObject: port  forKey:(id)kSecAttrPort];
    [query setObject: user  forKey:(id)kSecAttrAccount];
    [query setObject: (id)kSecMatchLimitOne  forKey:(id)kSecMatchLimit];
    [query setObject: (id)kCFBooleanTrue  forKey:(id)kSecReturnAttributes];
    [query setObject: (id)kCFBooleanTrue  forKey:(id)kSecReturnData];

    CFDictionaryRef credentials = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, (CFTypeRef*)&credentials);
    
    if (status == noErr) {
        NSDictionary *credentialsDict = (__bridge NSDictionary*) credentials;
        NSData *passwordData = credentialsDict[(__bridge NSString*) kSecValueData];
        NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        return password;
    } else {
        return nil;
    }
}

- (BOOL) resolveAutoProxyUrl:(NSURL*)url targetURL: (NSURL*)target {
    CFStreamClientContext context = {0, (void *)CFBridgingRetain(self), nil, nil, nil};
    CFRunLoopSourceRef runLoopSource = CFNetworkExecuteProxyAutoConfigurationURL((__bridge CFURLRef)url, (__bridge CFURLRef)target, ResultCallback, &context);
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
    CFRunLoopRun();
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoopSource);
    return [self.proxies count] > 0;
}

- (BOOL) resolveAutoProxyScript:(NSString*)script targetURL: (NSURL*)target {
    CFStreamClientContext context = {0, (void *)CFBridgingRetain(self), nil, nil, nil};
    CFRunLoopSourceRef runLoopSource = CFNetworkExecuteProxyAutoConfigurationScript((__bridge CFStringRef)script, (__bridge CFURLRef)target, ResultCallback, &context);
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
    CFRunLoopRun();
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoopSource);
    return [self.proxies count] > 0;
}

- (void)appendProxy:(YSFPPProxy *)proxy {
    [self.proxies addObject:proxy];
}

@end
