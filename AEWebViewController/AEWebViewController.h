//
//  AEWebViewController.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AEWebProgressView.h"
#import "AEWebWKComponent.h"
#import "SensorsAnalyticsSDK.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - AEWebViewDelegate

@class AEWebViewController;

/// WKWebView的映射协议方法
@protocol AEWebViewDelegate <NSObject>

@optional

/// 开始加载
- (void)webViewViewController:(AEWebViewController *)webViewController didStartLoadingURL:(NSURL *)URL;
/// 加载完成
- (void)webViewViewController:(AEWebViewController *)webViewController didFinishLoadingURL:(NSURL *)URL;
/// 加载失败
- (void)webViewViewController:(AEWebViewController *)webViewController didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewViewController:(AEWebViewController *)component decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
/// 内容加载终止【大部分会白屏】
- (void)webViewViewController:(AEWebViewController *)component processDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0));
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewViewController:(AEWebViewController *)component decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;


@end

@interface AEWebViewController : UIViewController<WKNavigationDelegate,SAAutoTracker>

#pragma mark - Initialize

/// WKWebView 类方法初始化
+ (instancetype)wkWebView;

/// 实例方法初始化
- (instancetype)initWithWKConfiguration:(nullable WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Property

/// WKWebView组件
@property (nonatomic, strong, readonly) AEWebBaseComponent *webViewComponent;

@property (nonatomic, weak) id<AEWebViewDelegate> delegate;

/// 当前刷新失败页面的手势，默认添加在 refreshView 上
/// 可以将它从 refreshView 移除，然后添加到想要实现点击事件的 view 上
///（注意：需要在 setRefreshView 之后调用才会生效）
@property (nonatomic, strong, readonly) UITapGestureRecognizer *failTapGestureRecognizer;

/// 导航栏标题
@property (nonatomic, copy) NSString *barTitle;

/// 导航栏标题颜色
@property (nonatomic, copy) UIColor *barTitleColor;

/// 自定义导航栏的 barTintColor
@property (nonatomic, strong) UIColor *barTintColor;

/// 导航栏标题按钮
@property (nonatomic, strong) UIButton *titleButton;

/// 左边返回按钮，如果设置，则不使用默认的
/// 默认功能如下：
/// 有多级页面的时候展示 ← ×
/// 无多级页面的时候展示 ←
@property (nonatomic, strong) UIButton *leftButton;

/// 默认的返回按钮，可以自定义属性
@property (nonatomic, strong, readonly) UIButton *webBackButton;

/// 默认的关闭按钮，可以自定义属性
@property (nonatomic, strong, readonly) UIButton *webCloseButton;

/// 右边按钮 默认隐藏
@property (nonatomic, strong) UIButton *rightButton;

/// 是否显示导航栏
@property (nonatomic, assign) BOOL showNavigationBar;

/// 默认的进度条添加在 navigationController 上
/// 若没有 navigationController
/// 则加载在 CustomHeaderView 上，也可以自己定义实现
@property (nonatomic, strong, readonly) AEWebProgressView *progressView;

/// 是否显示伪进度条，默认为 YES
@property (nonatomic, assign) BOOL showProgress;

/// 是否开启自动识别页面显示叉号功能 默认为 YES
@property (nonatomic, assign) BOOL showAutoBackItem;

/// 默认的空白视图，可以自定义实现
@property (nonatomic, strong) UIView *refreshView;

/// 是否在导航栏显示 URL 默认 NO
@property (nonatomic, assign) BOOL showsURLInNavigationBar;

/// 是否显示网页的 title 为标题 默认 YES
@property (nonatomic, assign) BOOL showsPageTitleInNavigationBar;

/// 当前正在使用的 webView 【目前只能是WKWebView】
@property (nonatomic, assign, readonly) UIView *webView;


#pragma mark - Public Method

/// 加载 URL 请求
- (void)loadURL:(NSURL *)URL;

/// 加载 URL 字符串请求
- (void)loadURLString:(NSString *)URLString;

/// 加载 HTML 字符串
- (void)loadHTMLString:(NSString *)HTMLString;

/// 加载本地 HTML 字符串
- (void)loadHTMLString:(NSString *)HTMLString baseURl:(nullable NSURL *)baseUrl;

/// 加载请求
- (void)loadRequest:(NSURLRequest *)request;

/// 重新设置 webView 控件
- (void)resetWebView;

/// 页面返回
- (void)close;

@end

NS_ASSUME_NONNULL_END
