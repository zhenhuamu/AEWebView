//
//  AEWebBaseComponent.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "AEWebViewController_Define.h"


NS_ASSUME_NONNULL_BEGIN

@class AEWebBaseComponent;

@protocol AEWebViewComponentDelegate <NSObject>

/// 开始加载
- (void)webViewComponent:(AEWebBaseComponent *)component didStartLoadURL:(NSURL *)URL;
/// 加载完成
- (void)webViewComponent:(AEWebBaseComponent *)component didFinishLoadURL:(NSURL *)URL;
/// 加载失败
- (void)webViewComponent:(AEWebBaseComponent *)component didFailLoadURL:(NSURL *)URL error:(NSError *)error;
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewComponent:(AEWebBaseComponent *)component decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
/// 内容加载终止【大部分会白屏】
- (void)webViewComponent:(AEWebBaseComponent *)component processDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0));
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewComponent:(AEWebBaseComponent *)component decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

@end

@protocol AEWebViewComponentBehavior <NSObject>

/// viewDidLoad 调用
- (void)ae_viewDidLoadWithNav:(BOOL)fakeNavigationController superView:(UIView *)superView;
/// viewWillAppear 调用
- (void)ae_viewWillAppear:(BOOL)animated;
/// dealloc 调用
- (void)ae_dealloc;
/// 更新标题
- (void)ae_updateTitle:(UIButton *)titleButton showUrl:(BOOL)showUrl showsPageTitle:(BOOL)showsPageTitle;
/// 加载请求
- (void)ae_loadRequest:(NSURLRequest *)request;
/// 加载 HTML 字符串
- (void)ae_loadHTMLString:(NSString *)HTMLString;
/// 加载本地 HTML 字符串
- (void)ae_loadHTMLString:(NSString *)HTMLString baseURl:(nullable NSURL *)baseUrl;
/// 页面返回
- (void)ae_backAction:(id)sender;
/// WEB是否可以后退
- (BOOL)ae_canGoBack;
/// WEB后退个数
- (NSInteger)ae_goBackPageCount;
/// 失败重新刷新
- (void)ae_failUrlRefresh;
/// WK后退
- (void)ae_goBack;
/// WEB
- (UIView *)ae_webView;
/// 重置
- (void)ae_resetWebView;

@end

@interface AEWebBaseComponent : NSObject<AEWebViewComponentBehavior>

/// WKWebView 请求回调
@property (weak, nonatomic) id <AEWebViewComponentDelegate> delegate;
/// 当前地址
@property (strong, nonatomic, readonly) NSURL *currentURL;
/// 失败地址
@property (strong, nonatomic, readonly) NSURL *failURL;
/// 是否是假的导航栏
@property (assign, nonatomic) BOOL fakeNavigationBar;
/// 是否是假的进度条
@property (assign, nonatomic) BOOL fakeProgress;
/// 更新标题
@property (copy, nonatomic) AEWebViewAction ae_updateTitle;
/// 更新左边按钮区域
@property (copy, nonatomic) AEWebViewAction ae_updateLeftBarButtonItems;
/// 更新右边按钮区域
@property (copy, nonatomic) AEWebViewAction ae_updateRightBarButtonItems;
/// 添加刷新视图
@property (copy, nonatomic) AEWebViewAction ae_addRefreshView;
/// 移除刷新视图
@property (copy, nonatomic) AEWebViewAction ae_removeRefreshView;
/// 进度条开始
@property (copy, nonatomic) AEWebViewAction ae_startProgress;
/// 进度条结束
@property (copy, nonatomic) AEWebViewAction ae_endProgress;
/// WEB进度
@property (copy, nonatomic) AEWebViewRefreshProgressValue ae_updateProgress;


@end

NS_ASSUME_NONNULL_END
