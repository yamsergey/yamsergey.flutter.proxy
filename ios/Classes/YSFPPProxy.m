//
//  YSFPPProxy.m
//  MacOSProxyResolver
//
//  Created by Sergey Yamshchikov on 07.02.21.
//  Copyright © 2021 Sergey Yamshchikov. All rights reserved.
//

#import "YSFPPProxy.h"

@implementation YSFPPProxy

@synthesize host = _host;
@synthesize port = _port;
@synthesize user = _user;
@synthesize password = _password;

- (instancetype)initWithHost:(nullable NSString *)host port:(nullable NSString *) port user: (nullable NSString *)user password: (nullable NSString *) password type:(YSFPPProxyType) type
{
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _user = user;
        _password = password;
        _type = type;
    }
    return self;
}

- (NSString*)host {
    return [self toStringForString:_host];
}

- (NSString*)port {
    return [self toStringForString:_port];
}

- (NSString*)user {
    return [self toStringForString:_user];
}

- (NSString*)password {
    return [self toStringForString:_password];
}

- (NSString*)typeString {
    switch (self.type) {
        case ySFPPHTTPS:
            return @"https";
            break;
        case ySFPPHTTP:
            return @"http";
            break;
        case ySFPPNONE:
            return @"none";
            break;
    }
}

- (NSString*) toStringForString:(nullable NSString *)value {
    if (value) {
        return value;
    } else {
        return @"";
    }
}

- (NSString*)description {
    return [NSString stringWithFormat:@"{\"host\": \"%@\", \"port\": \"%@\", \"user\": \"%@\", \"password\": \"%@\", \"type\": \"%@\"}", self.host, self.port, self.user, self.password, [self typeString]];
}

@end
