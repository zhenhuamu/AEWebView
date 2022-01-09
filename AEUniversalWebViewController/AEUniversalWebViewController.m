//
//  AEUniversalWebViewController.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEUniversalWebViewController.h"
#import "AEHandleMacros.h"
#import "AEJavaScriptResponse.h"

@interface AEUniversalWebViewController ()

@end

@implementation AEUniversalWebViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.bridgeManager = nil;
    self.pluginManager = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetManager];
}

#pragma mark - Rewrite

- (void)resetWebView {
    [super resetWebView];
    [self resetManager];
}

#pragma mark - Setup

- (void)resetManager {
    self.bridgeManager = nil;
    self.pluginManager = nil;
    self.bridgeManager = [AEJSBridgeManager new];
    self.pluginManager = [AEJSPluginManager new];
    WKWebView *webView = (WKWebView *)self.webView;
    [_bridgeManager setupBridge:webView navigationDelegate:webView.navigationDelegate ? : self];
    [_pluginManager setupPlugin:self nameSpace:[self pluginNameSpace]];
    [self registerBridge];
    [self registerPlugin];
}

/// 桥接注册【供子类实现】
- (void)registerBridge {
}

/// 组件注册【供子类实现】
- (void)registerPlugin {
}

/// JS命名空间【供子类实现】不现实则不使用
- (NSString *)pluginNameSpace {
    return @"";
}

/// 日志输出【供子类实现】
- (void)debugLogs:(NSString *)logs {
}

@end
