//
//  AEJavaScriptResponse.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEJavaScriptResponse.h"

static NSString * const jsSuccessCode = @"0";

@implementation AEJavaScriptResponse

+ (NSString *)responseCode:(NSString *)code message:(NSString *)message result:(id)result {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:code forKey:@"code"];
    [dic setValue:message forKey:@"message"];
    [dic setValue:result forKey:@"result"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)success {
    return [self responseCode:jsSuccessCode message:nil result:nil];
}

+ (NSString *)result:(id)result {
    return [self responseCode:jsSuccessCode message:nil result:result];
}


@end
