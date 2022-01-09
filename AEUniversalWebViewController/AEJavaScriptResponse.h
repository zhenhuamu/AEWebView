//
//  AEJavaScriptResponse.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEJavaScriptResponse : NSObject

+ (NSString *)success;

+ (NSString *)result:(id)result;

+ (NSString *)responseCode:(NSString *)code message:(nullable NSString *)message result:(nullable id)result;


@end

NS_ASSUME_NONNULL_END
