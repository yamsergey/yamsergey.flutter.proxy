//
//  YSFPPProxiesFetcher.h
//  MacOSProxyResolver
//
//  Created by Sergey Yamshchikov on 06.02.21.
//  Copyright © 2021 Sergey Yamshchikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFPPProxy.h"
#import "YSFPPProxyTypes.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<YSFPPProxy*> YSFPPProxiesArray;

@interface YSFPPProxiesResolver : NSObject

@property (readonly) YSFPPProxiesArray* proxies;

- (BOOL) resolve: (NSString*)url;
- (NSString*) proxiesAsJson;
- (void) appendProxy: (YSFPPProxy*) proxy;

@end

NS_ASSUME_NONNULL_END
