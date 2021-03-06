//
//  AEJSBridgeManager.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^AEResponseCallback)(id _Nullable responseData);
typedef void (^AEDictResponseCallback)(NSDictionary * _Nullable responseData);

typedef void (^AEVoidHandler)(void);
typedef void (^AEDictHandler)(NSDictionary * _Nonnull data);
typedef void (^AEDictRespHandler)(NSDictionary * _Nonnull data, AEResponseCallback _Nullable responseCallback);
typedef void (^AEHandler)(id _Nonnull data, AEResponseCallback _Nullable responseCallback);


NS_ASSUME_NONNULL_BEGIN

@protocol AEBridgeProtocol <NSObject>

@required

/// js调用native的方法名
- (NSString *)handlerName;

@optional

/// native接收到的js传过来的数据
- (void)didReceiveMessage:(id)message;

- (void)didReceiveMessage:(id)message hander:(AEResponseCallback)hander;

@end

@interface AEJSBridgeManager : NSObject

/// 是否输出日志
+ (void)enableLogging;

/**
 初始化Bridge
 
 @param webView webView
 param navigationDelegate 需要自定义实现navigationDelegate的方法
 */
- (void)setupBridge:(WKWebView *)webView;

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id _Nullable)delegate;

#pragma mark - single

/**
 注册方法，供JS端调用
 
 @param handlerName 方法名
 @param handler 回调
 */
- (void)registerHandler:(NSString*)handlerName voidHandler:(AEVoidHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictHandler:(AEDictHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(AEDictRespHandler)handler;

- (void)registerHandler:(NSString*)handlerName handler:(AEHandler)handler;

- (void)registerHandler:(id<AEBridgeProtocol>)handler;

#pragma mark - call

/**
 调用在JS端已经预埋好的方法
 
 @param handlerName 方法名
 param data 传递的数据
 param responseCallback JS接受后的回调
 */
- (void)callHandler:(NSString*)handlerName;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data responseCallback:(AEResponseCallback _Nullable)responseCallback;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data dictResponseCallback:(AEDictResponseCallback _Nullable)responseCallback;

#pragma mark - multiple

/**
 初始化遵循AEBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<AEBridgeProtocol>> *)handlers;

/**
 handers的映射关系组
 */
@property (nonatomic, strong, readonly)NSMutableDictionary *dictHanders;

@end

NS_ASSUME_NONNULL_END
