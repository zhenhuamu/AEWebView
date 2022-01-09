//
//  AEJSPluginManager.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/29.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AEJSPluginManager,AEWebViewController;

@protocol AEJSActionPluginProtocol<NSObject>

@required

/**
 方法名
 
 @return 方法名字符串
 */
- (NSString *)funcName;

@optional

/**
 客户端接收到js方法的回调

 @param plugin js 管理器
 @param message 接受到的消息
 */
- (void)actionPlugin:(AEJSPluginManager *)plugin vc:(AEWebViewController *)vc didReceiveScriptMessage:(id)message;


@end

@protocol AEJSStaticPluginProtocol<NSObject>

@required

/**
 方法名

 @return 方法名字符串
 */
- (NSString *)funcName;

/**
 方法结果

 @return 方法结果字符串
 */
- (NSString *)funcResult;

@end

@interface AEJSPluginManager : NSObject

/**
 初始化 Plugin
 @param nameSpace 命名空间 无则不使用
 @param vc WebViewController
 param navigationDelegate 需要自定义实现navigationDelegate的方法
 */
- (void)setupPlugin:(AEWebViewController *)vc nameSpace:(nullable NSString *)nameSpace;

- (void)addStaticPlugin:(id <AEJSStaticPluginProtocol>)plugin API_AVAILABLE(ios(8.0));

- (void)addActionPlugin:(id <AEJSActionPluginProtocol>)plugin API_AVAILABLE(ios(8.0));

/// Native回调JS方法【单参数】
-(void)evaluateJavaScriptMethod:(NSString *)method param:(NSString *)paramStr isJson:(BOOL)isJson;

-(void)evaluateJavaScriptMethod:(NSString *)method param:(NSString *)paramStr isJson:(BOOL)isJson completion:(void (^ _Nullable)(_Nullable id))completion;

/// Native回调JS方法【多参数】
/// 注意参数不添加"",如果需要，例如("abc",{"name":"xiaoming"})请在外部添加
-(void)evaluateJavaScriptMethod:(NSString *)method paramArray:(NSArray<NSString *> *)paramArray isJson:(BOOL)isJson;

-(void)evaluateJavaScriptMethod:(NSString *)method paramArray:(NSArray<NSString *> *)paramArray isJson:(BOOL)isJson completion:(void (^ _Nullable)(_Nullable id))completion;

/// 是否输出日志
- (void)setEnableLog:(BOOL)enableLog;

/// 日志输出 主要供重写扩展
-(void)debugLogs:(NSString *)logs;

@end

NS_ASSUME_NONNULL_END
