//
//  AEUniversalWebViewController.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebViewController.h"
#import "AEJSBridgeManager.h"
#import "AEJSPluginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AEUniversalWebViewController : AEWebViewController

/// 桥接管理器
@property (strong, nonatomic, nullable) AEJSBridgeManager *bridgeManager;
/// 组件管理器
@property (strong, nonatomic, nullable) AEJSPluginManager *pluginManager;

/// 桥接注册【供子类实现】
- (void)registerBridge;

/// 组件注册【供子类实现】
- (void)registerPlugin;

/// JS命名空间【供子类实现】不现实则不使用
- (NSString *)pluginNameSpace;

/// 日志输出【供子类实现】
- (void)debugLogs:(NSString *)logs;

@end

NS_ASSUME_NONNULL_END
