//
//  AEWebWKComponent.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebBaseComponent.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEWebWKComponent : AEWebBaseComponent

- (instancetype)initWithWKConfiguration:(WKWebViewConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
