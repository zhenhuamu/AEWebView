//
//  AEJSPluginManager.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/29.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEJSPluginManager.h"
#import "AEWebViewController.h"

@interface AEJSPluginManager()<WKScriptMessageHandler>

@property (weak, nonatomic) AEWebViewController *viewController;

@property (copy, nonatomic) NSString *nameSpace;

@property (strong, nonatomic) NSMutableDictionary *messageHandlers;

@property (strong, nonatomic) NSMutableDictionary *plugins;

@property (assign, nonatomic) BOOL enableLogs;

@end

@implementation AEJSPluginManager

- (void)setupPlugin:(AEWebViewController *)vc nameSpace:(nullable NSString *)nameSpace {
    self.viewController = vc;
    self.nameSpace = nameSpace;
}

#pragma mark - addUserScript 方法【注册方法给H5调用，并可以返回数据】

- (void)addStaticPlugin:(id<AEJSStaticPluginProtocol>)plugin {
    if (![plugin respondsToSelector:@selector(funcName)] || ![plugin respondsToSelector:@selector(funcResult)]) {
        return ;
    }
    NSString *funcName = [plugin funcName];
    NSString *result = [plugin funcResult];
    if ([_viewController.webView isKindOfClass:WKWebView.class]) {
        WKWebView *webView = (WKWebView *)_viewController.webView;
        WKUserContentController *userContent = webView.configuration.userContentController;
        WKUserScript *userScript = [self wkUserScriptWithFuncName:funcName funcResult:result];
        [userContent addUserScript:userScript];
        [webView reloadFromOrigin];
        [self debugLogs:userScript.source];
    }
}

- (WKUserScript *)wkUserScriptWithFuncName:(NSString *)funcName
                                funcResult:(NSString *)funcResult API_AVAILABLE(ios(8.0)) {
    NSString *injectionCode = [self injectionCodeWithFuncName:funcName funcResult:funcResult];
    if (!injectionCode) {
        return nil;
    }
    WKUserScript *userScrpit = [[WKUserScript alloc] initWithSource:injectionCode
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:NO];
    return userScrpit;
}

- (NSString *)injectionCodeWithFuncName:(NSString *)funcName
                             funcResult:(NSString *)funcResult {
    if (!funcName || !funcResult) {
        return nil;
    }
    NSString *injectionCode = @"";
    if (self.nameSpace.length > 0) {
        injectionCode = [NSString stringWithFormat:@"if(typeof %@ == 'undefined') {window.%@ = {}};window.%@.%@=function(){return '%@';}",_nameSpace,_nameSpace,_nameSpace,funcName,funcResult];
    }else {
        injectionCode = [NSString stringWithFormat:@"function %@() { return '%@'; }",funcName,funcResult];
    }
    return injectionCode;
}

#pragma mark - addScriptMessageHandler 方法【注册方法给H5调用，并可以接受数据】

- (void)addActionPlugin:(id<AEJSActionPluginProtocol>)plugin {
    if (![plugin respondsToSelector:@selector(funcName)]) {
        return ;
    }
    NSString *funcName = [plugin funcName];
    [self.plugins setValue:plugin forKey:funcName];
    if ([_viewController.webView isKindOfClass:WKWebView.class]) {
        WKWebView *webView = (WKWebView *)_viewController.webView;
        WKUserContentController *userContent = webView.configuration.userContentController;
        [userContent addScriptMessageHandler:self
                                        name:funcName];
    }
}

#pragma mark -Get Method

- (NSMutableDictionary *)plugins {
    if (!_plugins) {
        _plugins = [NSMutableDictionary dictionary];
    }
    return _plugins;
}

- (NSMutableDictionary *)messageHandlers {
    if (!_messageHandlers) {
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return _messageHandlers;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message API_AVAILABLE(ios(8.0)) {
    NSString *functionName = message.name;
    id<AEJSActionPluginProtocol> plugin = [_plugins objectForKey:functionName];
    if (!plugin) {
        return ;
    }
    id data = message.body;
    if ([plugin respondsToSelector:@selector(actionPlugin:vc:didReceiveScriptMessage:)]) {
        /// 在主线程回调
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [plugin actionPlugin:strongSelf vc:_viewController didReceiveScriptMessage:data];
            if (self.enableLogs) {
                [self debugLogs:[message.name stringByAppendingString:[self dealData:data]]];
            }
        });
    }
}

#pragma mark - Native 调用 JS 方法

/// Native回调JS方法
-(void)evaluateJavaScriptMethod:(NSString *)method param:(NSString *)paramStr isJson:(BOOL)isJson{
    [self evaluateJavaScriptMethod:method param:paramStr isJson:isJson completion:nil];
}

-(void)evaluateJavaScriptMethod:(NSString *)method param:(NSString *)paramStr isJson:(BOOL)isJson completion:(void (^ _Nullable)(_Nullable id))completion {
    NSString *jsString = @"";
    if (isJson) {
        jsString = [NSString stringWithFormat:@"%@(%@)",method,paramStr];
    }else {
        jsString = [NSString stringWithFormat:@"%@('%@')",method,paramStr];
    }
    if ([_viewController.webView isKindOfClass:WKWebView.class]) {
        WKWebView *webView = (WKWebView *)_viewController.webView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if (completion) {
                    completion(result);
                }
            }];
            [self debugLogs:jsString];
        });
    }
}

/// Native回调JS方法【返回值为多参数】
/// 注意参数不添加"",如果需要，例如("abc",{"name":"xiaoming"})请在外部添加
-(void)evaluateJavaScriptMethod:(NSString *)method paramArray:(NSArray<NSString *> *)paramArray isJson:(BOOL)isJson {
    [self evaluateJavaScriptMethod:method paramArray:paramArray isJson:isJson completion:nil];
}

-(void)evaluateJavaScriptMethod:(NSString *)method paramArray:(NSArray<NSString *> *)paramArray isJson:(BOOL)isJson completion:(void (^ _Nullable)(_Nullable id))completion {
    __block NSMutableString *jsString = @"";
    [paramArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSString.class]) {
            jsString = [jsString stringByAppendingString:obj];
            if (paramArray.count != (idx + 1)) {
                jsString = [jsString stringByAppendingString:@","];
            }
        }
    }];
    [self evaluateJavaScriptMethod:method param:jsString isJson:YES completion:completion];
    [self debugLogs:jsString];
}

/// 是否输出日志
- (void)setEnableLog:(BOOL)enableLog {
    self.enableLogs = enableLog;
}

///日志输出
-(void)debugLogs:(NSString *)logs {
    if (self.enableLogs && [self.viewController isKindOfClass:AEUniversalWebViewController.class]) {
        [((AEUniversalWebViewController *)self.viewController) debugLogs:logs];
    }
}

#pragma mark - Tool method

- (NSString *)dealData:(id)data {
    if ([data isKindOfClass:NSString.class]) {
        return (NSString *)data;
    }else if ([data isKindOfClass:NSDictionary.class]) {
        return [self jsonPrettyStringEncoded:((NSDictionary *)data)];
    }else if ([data isKindOfClass:NSNumber.class]) {
        return ((NSNumber *)data).stringValue;
    }
    return nil;
}

- (NSString *)jsonPrettyStringEncoded:(id)data {
    if ([NSJSONSerialization isValidJSONObject:data]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

@end
