//
//  AEJSBridgeManager.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEJSBridgeManager.h"
#import "WKWebViewJavascriptBridge.h"

@interface AEJSBridgeManager ()

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, strong) NSArray< id<AEBridgeProtocol> > * handers;
@property (nonatomic, strong) NSMutableDictionary *dictHanders;

@end

@implementation AEJSBridgeManager

#pragma mark - 日志

+ (void)enableLogging {
    [WKWebViewJavascriptBridge enableLogging];
}

#pragma mark - setup

- (void)setupBridge:(WKWebView *)webView {
    [self setupBridge:webView navigationDelegate:nil];
}

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id)delegate {
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    if (delegate) {
        [_bridge setWebViewDelegate:delegate];
    }
}

#pragma mark - register

- (void)registerHandler:(NSString*)handlerName voidHandler:(AEVoidHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (handler) { handler();}
        }];
    }
}

- (void)registerHandler:(NSString*)handlerName dictHandler:(AEDictHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data);
            }
        }];
    }
}

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(AEDictRespHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data, responseCallback);
            }
        }];
    }
}

- (void)registerHandler:(NSString *)handlerName handler:(AEHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:handler];
    }
}

- (void)registerHandler:(id<AEBridgeProtocol>)handler {
    NSString *handlerName = nil;
    if ([handler respondsToSelector:@selector(handlerName)]) {
        handlerName = [handler handlerName];
    }
    if (_bridge && handlerName) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if ([handler respondsToSelector:@selector(didReceiveMessage:hander:)]) {
                [handler didReceiveMessage:data hander:responseCallback];
            }
            if ([handler respondsToSelector:@selector(didReceiveMessage:)]) {
                [handler didReceiveMessage:data];
            }
        }];
    }
}

#pragma mark - call

- (void)callHandler:(NSString*)handlerName {
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString*)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(AEResponseCallback)responseCallback {
    if (_bridge) {
        [_bridge callHandler:handlerName data:data responseCallback:responseCallback];
    }
}

- (void)callHandler:(NSString*)handlerName data:(id)data dictResponseCallback:(AEDictResponseCallback)responseCallback {
    if (_bridge) {
        [_bridge callHandler:handlerName data:data responseCallback:^(id responseData) {
            if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
                responseCallback((NSDictionary *)responseData);
            }
        }];
    }
}

#pragma mark - multiple

/**
 初始化遵循HJBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<AEBridgeProtocol>> *)handlers {
    for (id<AEBridgeProtocol> handler in handlers) {
        [self addHander:handler];
    }
}

- (void)addHander:(id<AEBridgeProtocol>)handler {
    NSString *handerName = nil;
    if ([handler respondsToSelector:@selector(handlerName)]) {
        handerName = [handler handlerName];
    }
    if (!handerName || [_dictHanders objectForKey:handerName]) { return; }
    [_dictHanders setValue:handler forKey:handerName];
    [self registerHandler:handerName handler:^(id  _Nonnull data, AEResponseCallback  _Nullable responseCallback) {
        if ([handler respondsToSelector:@selector(didReceiveMessage:hander:)]) {
            [handler didReceiveMessage:data hander:responseCallback];
        }
        if ([handler respondsToSelector:@selector(didReceiveMessage:)] && [data isKindOfClass:[NSDictionary class]]) {
            [handler didReceiveMessage:(NSDictionary *)data];
        }
    }];
}

@end
