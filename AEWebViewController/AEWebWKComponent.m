//
//  AEWebWKComponent.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebWKComponent.h"

static void *AEWebContext = &AEWebContext;

@interface AEWebWKComponent()<WKNavigationDelegate>
{
    NSURL *_currentURL;
    NSURL *_failURL;
}

@property (strong, nonatomic) NSURL *currentURL;
@property (strong, nonatomic) NSURL *failURL;
@property (strong, nonatomic) WKWebView *webView;
@property (assign, nonatomic, getter=isRegisterObserver) BOOL registerObserver;

@end

@implementation AEWebWKComponent

- (void)dealloc {
    self.webView = nil;
}

@dynamic currentURL;
@dynamic failURL;

- (void)setCurrentURL:(NSURL *)currentURL {
    _currentURL = currentURL;
}

- (void)setFailURL:(NSURL *)failURL {
    _failURL = failURL;
}

- (NSURL *)failURL {
    return _failURL;
}

- (NSURL *)currentURL {
    return _currentURL;
}

#pragma mark - Public Method

- (instancetype)initWithWKConfiguration:(WKWebViewConfiguration *)configuration {
    if (self = [super init]) {
        [self setUpWebViewWithConfiguration:configuration];
    }
    return self;
}

#pragma mark - AEWebViewComponentBehavior

- (void)ae_viewDidLoadWithNav:(BOOL)fakeNavigationController superView:(UIView *)superView {
    self.fakeNavigationBar = fakeNavigationController;
    [self setUpObserver];
    [self setUpLayoutWithSuperView:superView];
}

- (void)ae_viewWillAppear:(BOOL)animated {
    if (!self.webView || self.webView.loading) {
        return;
    }
}

- (void)ae_dealloc {
    [self.webView setNavigationDelegate:nil];
    [self cleanObserver];
    self.webView = nil;
}

- (void)ae_updateTitle:(UIButton *)titleButton showUrl:(BOOL)showUrl showsPageTitle:(BOOL)showsPageTitle {
    if (self.webView.loading) {
        if (!showUrl) {
            return;
        }
        NSString *URLString = [self.webView.URL absoluteString];
        URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        URLString = [URLString substringToIndex:[URLString length] - 1];
        [titleButton setTitle:URLString forState:UIControlStateNormal];
    } else {
        if (!showsPageTitle) {
            return;
        }
        if (!self.webView) {
            return;
        }
        if (!self.webView.title || self.webView.title.length <= 0) {
            return ;
        }
        [titleButton setTitle:self.webView.title forState:UIControlStateNormal];
    }
}

- (void)ae_loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

- (void)ae_loadHTMLString:(NSString *)HTMLString {
    [self.webView loadHTMLString:HTMLString baseURL:nil];;
}

- (void)ae_loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl {
    [self.webView loadHTMLString:HTMLString baseURL:baseUrl];
}

- (void)ae_backAction:(id)sender {
}

- (BOOL)ae_canGoBack {
    return self.webView.backForwardList.backList.count >= 1 && self.webView.canGoBack;
}

- (NSInteger)ae_goBackPageCount {
    return self.webView.backForwardList.backList.count;
}

- (void)ae_failUrlRefresh {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.failURL]];
}

- (void)ae_goBack {
    [self.webView goBack];
}

- (UIView *)ae_webView {
    return self.webView;
}

- (void)ae_resetWebView {
    self.currentURL = nil;
    self.failURL = nil;
    [self resetWebView];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.fakeProgress) {
        self.ae_startProgress();
    }
    self.currentURL = webView.URL;
    self.ae_updateTitle();
    if ([self.delegate respondsToSelector:@selector(webViewComponent:didStartLoadURL:)]) {
        [self.delegate webViewComponent:self didStartLoadURL:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.ae_updateTitle();
    self.ae_removeRefreshView();
    self.ae_updateLeftBarButtonItems();
    if ([self.delegate respondsToSelector:@selector(webViewComponent:didFinishLoadURL:)]) {
        [self.delegate webViewComponent:self didFinishLoadURL:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.failURL = self.currentURL;
    self.ae_updateTitle();
    if (error.code != NSURLErrorCancelled) {
        self.ae_addRefreshView();
    }
    if ([self.delegate respondsToSelector:@selector(webViewComponent:didFailLoadURL:error:)]) {
        [self.delegate webViewComponent:self didFailLoadURL:webView.URL error:error];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.ae_updateTitle();
    if ([self.delegate respondsToSelector:@selector(webViewComponent:didFailLoadURL:error:)]) {
        [self.delegate webViewComponent:self didFailLoadURL:webView.URL error:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    self.ae_updateRightBarButtonItems();
    self.ae_updateLeftBarButtonItems();
    // 如果使用方需要拦截，则让使用方去拦截操作，如果使用方不需要拦截，则 SDK 内部处理
    if ([self.delegate respondsToSelector:@selector(webViewComponent:decidePolicyForNavigationAction:decisionHandler:)]) {
        if ([self.delegate webViewComponent:self decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler]) {
            return;
        }
    }
    NSURL *url = navigationAction.request.URL;
    if (![self requiredToOpenURL:url]) {
        if (!navigationAction.targetFrame) {
            [self ae_loadRequest:[NSURLRequest requestWithURL:url]];
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    } else if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if ([self requiredToFileURL:url]) {
            [self launchExternalURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    if ([self.delegate respondsToSelector:@selector(webViewComponent:processDidTerminate:)]) {
        [self.delegate webViewComponent:self processDidTerminate:webView];
    }
    // 解决白屏问题
    [webView reload];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 如果使用方需要拦截，则让使用方去拦截操作，如果使用方不需要拦截，则 SDK 内部处理
    if ([self.delegate respondsToSelector:@selector(webViewComponent:decidePolicyForNavigationResponse:decisionHandler:)]) {
        if ([self.delegate webViewComponent:self decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler]) {
            return;
        }
    }
    if (![navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
        return ;
    }
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    // 服务器返回 200 以外的状态码时，都调用请求失败的方法。
    if (response.statusCode == 200 || response.statusCode == 304) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:Kaeweb_estimatedProgress] && object == self.webView) {
        [self observeProgressChange:change context:context];
    } else if ([keyPath isEqualToString:Kaeweb_URL] && object == self.webView) {
        [self observeURLChange:change context:context];
    }
}

- (void)observeProgressChange:(NSDictionary *)change context:(void *)context {
    self.ae_updateProgress(self.webView.estimatedProgress);
}

- (void)observeURLChange:(NSDictionary *)change context:(void *)context {
    NSURL *newUrl = [change objectForKey:NSKeyValueChangeNewKey];
    NSURL *oldUrl = [change objectForKey:NSKeyValueChangeOldKey];
    if (AEWebStrIsEmpty(newUrl.absoluteString) &&
        !AEWebStrIsEmpty(oldUrl.absoluteString)) {
        [self.webView reload];
    };
}

#pragma mark - Private Method

/// Configuration 初始化
- (void)setUpWebViewWithConfiguration:(WKWebViewConfiguration *)configuration {
    if (configuration) {
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    } else {
        self.webView = [[WKWebView alloc] init];
    }
    self.webView.navigationDelegate = self;
}

/// 属性监听
- (void)setUpObserver {
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:AEWebContext];
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(URL))
                      options:0
                      context:AEWebContext];
    self.registerObserver = YES;
}

/// webview视图初始化
- (void)setUpLayoutWithSuperView:(UIView *)superView {
    [superView addSubview:self.webView];
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    // align self.webView from the left and right
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0@250-[_webView]-0@250-|"
                            options:0
                            metrics:nil
                              views:NSDictionaryOfVariableBindings(_webView)]];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0@250-[_webView]-0@250-|"
                            options:0
                            metrics:nil
                              views:NSDictionaryOfVariableBindings(_webView)]];
}

/// 移除观察者
- (void)cleanObserver {
    if (!self.webView || !self.isRegisterObserver) {
        return;
    }
    [self.webView removeObserver:self
                      forKeyPath:NSStringFromSelector(@selector(URL))];
    [self.webView removeObserver:self
                      forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    self.registerObserver = NO;
}

/// 重置WEB
- (void)resetWebView {
    if (!self.webView) {
        return ;
    }
    // 保留 superView
    UIView *superView = self.webView.superview;
    if (!superView) {
        return ;
    }
    [self.webView removeFromSuperview];
    // 清除观察者
    [self cleanObserver];
    // 清除代理
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    // 新建 webView
    WKWebViewConfiguration *configuration = self.webView.configuration;
    [self setUpWebViewWithConfiguration:configuration];
    // 设置约束
    [self setUpLayoutWithSuperView:superView];
    // 添加观察者
    [self setUpObserver];
}

/// URL验证
- (BOOL)requiredToOpenURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"http", @"https" ]];
    return ![validSchemes containsObject:URL.scheme];
}

/// file验证
- (BOOL)requiredToFileURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"file" ]];
    return ![validSchemes containsObject:URL.scheme];
}

/// openURL
- (void)launchExternalURL:(NSURL *)URL {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:URL
                                           options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @(NO) }
                                 completionHandler:^(BOOL success){
                                 }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:URL];
#pragma clang diagnostic pop
    }
}

@end
