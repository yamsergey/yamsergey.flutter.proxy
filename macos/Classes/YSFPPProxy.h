//
//  YSFPPProxy.h
//  MacOSProxyResolver
//
//  Created by Sergey Yamshchikov on 07.02.21.
//  Copyright © 2021 Sergey Yamshchikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFPPProxyTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFPPProxy : NSObject

@property (readonly, nullable) NSString *host;
@property (readonly, nullable) NSString *port;
@property (readonly, nullable) NSString *user;
@property (readonly, nullable) NSString *password;
@property (readonly) YSFPPProxyType type;

- (instancetype)initWithHost:(nullable NSString*)host port:(nullable NSString *) port user: (nullable NSString *)user password: (nullable NSString *) password type:(YSFPPProxyType) type;

- (NSString *) toStringForString:(nullable NSString*)value;

@end

NS_ASSUME_NONNULL_END
