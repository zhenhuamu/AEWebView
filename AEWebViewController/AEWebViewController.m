//
//  AEWebViewController.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebViewController.h"
#import "AEWebViewNavigationBar.h"


#define SELF_NAV self.navigationController

#define SELF_NAV_BAR self.navigationController.navigationBar


@interface AEWebViewController ()<AEWebViewComponentDelegate>
{
    UIView *_refreshView;
}

@property (nonatomic, strong) UIColor *originalTintColor;
@property (nonatomic, strong) UIColor *originalBarTintColor;
@property (nonatomic, strong) UIButton *wkTitleButton;

@property (nonatomic, strong, readwrite) AEWebProgressView *progressView;
@property (nonatomic, strong, readwrite) AEWebViewNavigationBar *customNavigationBar;

@property (nonatomic, strong, readwrite) UIButton *webBackButton;
@property (nonatomic, strong, readwrite) UIButton *webCloseButton;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *failTapGestureRecognizer;

@property (nonatomic, strong) AEWebBaseComponent *webViewComponent;
@property (nonatomic, weak) id <UIGestureRecognizerDelegate> originGesRecDelegate;


@end

@implementation AEWebViewController

#pragma mark - Dealloc

- (void)dealloc {
    [self.webViewComponent ae_dealloc];
}

#pragma mark - Static Initializers

+ (instancetype)wkWebView {
    return [[[self class] alloc] initWithWKConfiguration:nil];
}

#pragma mark - Initializers

/// 默认初始化 WK
- (instancetype)init {
    return [self initWithWKConfiguration:nil];
}

- (instancetype)initWithWKConfiguration:(WKWebViewConfiguration *)configuration {
    if (self = [super init]) {
        if ([WKWebView class]) {
            if (!configuration) {
                configuration = [WKWebViewConfiguration new];
            }
            if (!configuration.userContentController) {
                WKUserContentController *userContent = [WKUserContentController new];
                configuration.userContentController = userContent;
            }
            self.webViewComponent = [[AEWebWKComponent alloc] initWithWKConfiguration:configuration];
            [self setUpWebViewComponent];
        }
        self.showAutoBackItem = YES;
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
        self.showProgress = YES;
    }
    return self;
}

- (void)setUpWebViewComponent {
    [self.webViewComponent setDelegate:self];
    AEWEB_WEAK_SELF
    [self.webViewComponent setAe_updateTitle:^{
        AEWEB_STRONG_SELF
        [self updateTitle];
    }];
    [self.webViewComponent setAe_startProgress:^{
        AEWEB_STRONG_SELF
        [self startProgress];
    }];
    [self.webViewComponent setAe_endProgress:^{
        AEWEB_STRONG_SELF
        [self endProgress];
    }];
    [self.webViewComponent setAe_addRefreshView:^{
        AEWEB_STRONG_SELF
        [self addrefreshView];
    }];
    [self.webViewComponent setAe_removeRefreshView:^{
        AEWEB_STRONG_SELF
        [self removeRefreshView];
    }];
    [self.webViewComponent setAe_updateProgress:^(CGFloat value) {
        AEWEB_STRONG_SELF
        [self updateProgress:value];
    }];
    [self.webViewComponent setAe_updateLeftBarButtonItems:^{
        AEWEB_STRONG_SELF
        [self updateLeftBarButtonItems];
    }];
    [self.webViewComponent setAe_updateRightBarButtonItems:^{
        AEWEB_STRONG_SELF
        [self updateRightBarButtonItems];
    }];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL fakeNav = NO;
    if (self.showNavigationBar && !SELF_NAV) {
        fakeNav = YES;
    }
    [self.webViewComponent ae_viewDidLoadWithNav:fakeNav superView:self.view];
    [self setUpBaseUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_showProgress) {
        // 添加进度条
        [self addProgressView];
    }
    // 刷新标题
    [self updateTitle];
    // 导航栏手势
    if (self.navigationController) {
        if (self.navigationController.interactivePopGestureRecognizer.delegate) {
            _originGesRecDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
        }
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
    [self.webViewComponent ae_viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 导航栏还原
    [self resetNavigationBar];
    // 移除进度条
    [self removeProgressView];
    // 导航栏手势还原
    if (_originGesRecDelegate) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _originGesRecDelegate;
    } else {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - Component 回调

/// 更新标题
- (void)updateTitle {
    [self.webViewComponent ae_updateTitle:[self webTitleButton]
                                  showUrl:self.showsURLInNavigationBar
                           showsPageTitle:self.showsPageTitleInNavigationBar];
    /// 调整标题按钮尺寸
    [[self webTitleButton] sizeToFit];
}

/// 开始进度条
- (void)startProgress {
    if (self.progressView) {
        [self.progressView start];
    }
}

/// 结束进度条
- (void)endProgress {
    if (self.progressView) {
        [self.progressView endWithAnimated:NO];
    }
}

/// 添加刷新视图
- (void)addrefreshView {
    if (self.refreshView) {
        [self.view addSubview:_refreshView];
    }
}

/// 移除刷新视图
- (void)removeRefreshView {
    if (self.refreshView) {
        [self.refreshView removeFromSuperview];
    }
}

/// 更新进度
- (void)updateProgress:(CGFloat)estimatedProgress {
    AEWEB_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        AEWEB_STRONG_SELF
        BOOL animated = estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:estimatedProgress animated:animated];
    });
}

/// 更新左侧按钮
- (void)updateLeftBarButtonItems {
    // 如果有自定义的按钮，使用自定义的按钮
    if (_leftButton) {
        [self webSetLeftButtons:@[_leftButton]];
        return;
    }
    // 没有自定义的按钮，使用默认的按钮
    // 如果不开启自动更新按钮功能
    if (!_showAutoBackItem) {
        return;
    }
    // 如果可以返回
    if ([self.webViewComponent ae_canGoBack]) {
        // 如果是根控制器 肯定不显示 X 按钮
        if ([self checkSelfIsRootViewController]) {
            [self webSetLeftButtons:@[ self.webBackButton ]];
        } else {
            if ([self.webViewComponent ae_goBackPageCount] == 0) {
                [self webSetLeftButtons:@[ self.webBackButton ]];
            } else {
                [self webSetLeftButtons:@[ self.webBackButton, self.webCloseButton ]];
            }
        }
    } else {
        // 不能返回
        if ([self checkSelfIsRootViewController]) {
            [self webSetLeftButtons:nil];
        } else {
            [self webSetLeftButtons:@[ self.webBackButton ]];
        }
    }
}

/// 更新右侧按钮
- (void)updateRightBarButtonItems {
    if (!_rightButton) {
        return ;
    }
    [self webSetRightButtons:@[_rightButton]];
}

#pragma mark - BarButtonItems

- (void)setLeftButton:(UIButton *)leftButton {
    _leftButton = leftButton;
    [self updateLeftBarButtonItems];
}

- (void)setRightButton:(UIButton *)rightButton {
    _rightButton = rightButton;
    [self updateRightBarButtonItems];
}

/// 左侧按钮添加
- (void)webSetLeftButtons:(NSArray <UIButton *> *)buttons {
    if (SELF_NAV) {
        NSArray *rightItems = [self barButtonItemWithButtons:buttons];
        SELF_NAV.topViewController.navigationItem.leftBarButtonItems = rightItems;
    } else {
        [self.customNavigationBar setLeftButtons:buttons];
    }
}

/// 右侧按钮添加
- (void)webSetRightButtons:(NSArray <UIButton *> *)buttons {
    if (SELF_NAV) {
        NSArray *leftItems = [self barButtonItemWithButtons:buttons];
        SELF_NAV.topViewController.navigationItem.rightBarButtonItems = leftItems;
    } else {
        [self.customNavigationBar setLeftButtons:buttons];
    }
}

- (NSArray <UIBarButtonItem *> *)barButtonItemWithButtons:(NSArray <UIButton *> *)buttons {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0 ; i < buttons.count; i++) {
        UIButton *button = buttons[i];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        if (item) {
            [tempArray addObject:item];
        }
    }
    return tempArray;
}

#pragma mark - Setup UI

- (void)setUpBaseUI {
    // 配置导航栏
    [self setUpNavigationBar];
    // 左侧按钮和右侧按钮
    [self updateLeftBarButtonItems];
    [self updateRightBarButtonItems];
    // 设置title
    [self updateTitleButtonItems];
    // 自定义导航栏的 barTintColor
    [self resetBarTintColor];
}

#pragma mark - NavigationBar

- (void)setShowNavigationBar:(BOOL)showNavigationBar {
    _showNavigationBar = showNavigationBar;
    [self updateNavigationBar];
}

- (UIView *)webNavigationBar {
    if (SELF_NAV) {
        return SELF_NAV_BAR;
    } else {
        return self.customNavigationBar;
    }
}

- (void)setUpNavigationBar {
    // 是否显示导航栏
    if (!_showNavigationBar) {
        return ;
    }
    // 如果存在原生导航栏
    if (SELF_NAV) {
        SELF_NAV.interactivePopGestureRecognizer.enabled = YES;
        self.originalTintColor = SELF_NAV_BAR.tintColor;
        self.originalBarTintColor = SELF_NAV_BAR.barTintColor;
    } else {
        // 如果不存在原生导航栏
        [self addCustomHeaderView];
    }
}

- (void)updateNavigationBar {
    [[self webNavigationBar] setHidden:!_showNavigationBar];
}

- (void)resetNavigationBar {
    if (_originalTintColor) {
        if (SELF_NAV) {
            [SELF_NAV_BAR setTintColor:_originalTintColor];
        }
    }
    if (_originalBarTintColor) {
        if (SELF_NAV) {
            [SELF_NAV_BAR setBarTintColor:_originalBarTintColor];
        }
    }
}

#pragma mark - BarTitle

- (void)setBarTitleColor:(UIColor *)barTitleColor {
    _barTintColor = barTitleColor;
    [[self webTitleButton] setTitleColor:barTitleColor forState:UIControlStateNormal];
    [[self webTitleButton] sizeToFit];
}

- (void)setBarTitle:(NSString *)barTitle {
    _barTitle = barTitle;
    [[self webTitleButton] setTitle:barTitle forState:UIControlStateNormal];
    [[self webTitleButton] sizeToFit];
}

- (void)updateTitleButtonItems {
    UIColor *titleColor = [UIColor colorWithRed:68 / 255.0
                                          green:68 / 255.0
                                           blue:68 / 255.0
                                          alpha:1];
    _wkTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wkTitleButton.frame = CGRectMake(0, 0, 200, 44);
    _wkTitleButton.backgroundColor = [UIColor clearColor];
    [_wkTitleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_wkTitleButton setTitleColor:titleColor forState:UIControlStateNormal];
    // 如果设置过 控制器的 title 先展示控制器的 title
    if (self.title) {
        [_wkTitleButton setTitle:self.title forState:UIControlStateNormal];
    }
    [SELF_NAV.topViewController.navigationItem setTitleView:_wkTitleButton];
}

#pragma mark - BarTintColor

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    [self resetBarTintColor];
}

- (void)resetBarTintColor {
    if (_barTintColor) {
        if (SELF_NAV) {
            [SELF_NAV_BAR setBarTintColor:_barTintColor];
        } else {
            [self.customNavigationBar setBackgroundColor:_barTintColor];
        }
    }
}

#pragma mark - ProgressView

- (void)addProgressView {
    [[self webView] addSubview:self.progressView];
    self.progressView.alpha = 0.0f;
    [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self webView] addConstraints:[NSLayoutConstraint
       constraintsWithVisualFormat:@"H:|-0@250-[_progressView]-0@250-|"
                           options:0
                           metrics:nil
                             views:NSDictionaryOfVariableBindings(_progressView)]];
    // align _progressView from the bottom
    [[self webView] addConstraints:[NSLayoutConstraint
       constraintsWithVisualFormat:@"V:|-0@250-[_progressView]"
                           options:0
                           metrics:nil
                             views:NSDictionaryOfVariableBindings(_progressView)]];
    // height constraint
    [[self webView] addConstraints:[NSLayoutConstraint
       constraintsWithVisualFormat:@"V:[_progressView(==2@250)]"
                           options:0
                           metrics:nil
                             views:NSDictionaryOfVariableBindings(_progressView)]];
    // 防止出现约束动画
    [[self progressView] setNeedsLayout];
}

/// 移除进度条
- (void)removeProgressView {
    if (self.progressView) {
        [self.progressView removeFromSuperview];
    }
}

#pragma mark - CustomHeaderView

- (void)addCustomHeaderView {
    [self.view addSubview:self.customNavigationBar];
    [self.customNavigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    // align customNavigationBar from the top and bottom
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0@250-[_customNavigationBar]-0@250-|"
                            options:0
                            metrics:nil
                              views:NSDictionaryOfVariableBindings(_customNavigationBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0@250-[_customNavigationBar(==64@250)]"
                            options:0
                            metrics:nil
                              views:NSDictionaryOfVariableBindings(_customNavigationBar)]];
    if (self.title) {
        [self.customNavigationBar.titleButton setTitle:self.title forState:UIControlStateNormal];
    }
}

- (AEWebViewNavigationBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [AEWebViewNavigationBar navigationBar];
        [_customNavigationBar.backButton addTarget:self
                                            action:@selector(backButtonPressed:)
                                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _customNavigationBar;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RefreshView

- (void)setRefreshView:(UIView *)refreshView {
    _refreshView = refreshView;
    // 移除所有手势
    AEWEB_WEAK_SELF
    [[_refreshView gestureRecognizers] enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AEWEB_STRONG_SELF
        [self.refreshView removeGestureRecognizer:obj];
    }];
    // 添加刷新手势
    _failTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WebViewRefreshFailUrl)];
    [_refreshView addGestureRecognizer:_failTapGestureRecognizer];
}

#pragma mark - Public Method

- (void)loadRequest:(NSURLRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webViewComponent ae_loadRequest:request];
    });
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    [self loadURL:[NSURL URLWithString:URLString]];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    [self loadHTMLString:HTMLString baseURl:nil];
}

- (void)loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl {
    [self.webViewComponent ae_loadHTMLString:HTMLString baseURl:nil];
}

- (void)resetWebView {
    [self.webViewComponent ae_resetWebView];
}

/// 页面返回
- (void)close {
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIButton Target Action Methods

- (void)closeButtonPressed:(id)sender {
    [self close];
}

- (void)backButtonPressed:(id)sender {
    if ([self.webViewComponent ae_canGoBack]) {
        [self.webViewComponent ae_goBack];
        // 如果当前只有一个页面可以被返回，那返回之后需要对叉号进行处理
        if ([self.webViewComponent ae_goBackPageCount] == 1) {
            if ([self checkSelfIsRootViewController]) {
                [self webSetLeftButtons:@[]];
            } else {
                [self webSetLeftButtons:@[ self.webBackButton ]];
            }
        } else {
            [self webSetLeftButtons:@[ self.webBackButton, self.webCloseButton ]];
        }
    } else {
        [self closeButtonPressed:self.webCloseButton];
    }
    [self updateTitle];
}

/// 刷新失败 URL
- (void)WebViewRefreshFailUrl {
    [self.webViewComponent ae_failUrlRefresh];
}

#pragma mark - AEWebViewComponentDelegate

/// 开始加载
- (void)webViewComponent:(AEWebBaseComponent *)component didStartLoadURL:(NSURL *)URL {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:didStartLoadingURL:)]) {
        [self.delegate webViewViewController:self didStartLoadingURL:URL];
    }
}
/// 加载完成
- (void)webViewComponent:(AEWebBaseComponent *)component didFinishLoadURL:(NSURL *)URL {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:didFinishLoadingURL:)]) {
        [self.delegate webViewViewController:self didFinishLoadingURL:URL];
    }
}
/// 加载失败
- (void)webViewComponent:(AEWebBaseComponent *)component didFailLoadURL:(NSURL *)URL error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:didFailToLoadURL:error:)]) {
        [self.delegate webViewViewController:self didFailToLoadURL:URL error:error];
    }
}
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewComponent:(AEWebBaseComponent *)component decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:decidePolicyForNavigationAction:decisionHandler:)]) {
        return [self.delegate webViewViewController:self decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else {
        return NO;
    }
}
/// 内容加载终止【大部分会白屏】
- (void)webViewComponent:(AEWebBaseComponent *)component processDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:processDidTerminate:)]) {
        [self.delegate webViewViewController:self processDidTerminate:webView];
    }
}
/// 如果返回 NO 则使用 SDK 内部的拦截处理方案，如果返回 YES 则自己处理拦截方案
- (BOOL)webViewComponent:(AEWebBaseComponent *)component decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewViewController:decidePolicyForNavigationResponse:decisionHandler:)]) {
        return [self.delegate webViewViewController:self decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
    return NO;
}

#pragma mark - SAAutoTracker

/// 神策
- (NSDictionary *)getTrackProperties{
    return @{@"weburl": AESTRNOTNIL(self.webViewComponent.currentURL.absoluteString)};
}

#pragma mark - Private Method

/// 检查是否在首页
- (BOOL)checkSelfIsRootViewController {
    if (SELF_NAV) {
        if (SELF_NAV.viewControllers.count > 0 &&
            [SELF_NAV.viewControllers indexOfObject:SELF_NAV.topViewController] == 0) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Get

- (UIButton *)webTitleButton {
    if (SELF_NAV) {
        return self.wkTitleButton;
    } else {
        return self.customNavigationBar.titleButton;
    }
}

- (UIButton *)webBackButton {
    if (!_webBackButton) {
        NSString *backImgPath = [[NSBundle mainBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"];
        UIImage *backButtonItemImage =
        [[UIImage imageWithContentsOfFile:backImgPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _webBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _webBackButton.frame = CGRectMake(0, 0, 20, 44);
        [_webBackButton setImage:backButtonItemImage forState:UIControlStateNormal];
        [_webBackButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _webBackButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _webBackButton;
}

- (UIButton *)webCloseButton {
    if (!_webCloseButton) {
        NSString *closeImgPath = [[NSBundle mainBundle] pathForResource:@"nav_btn_close@3x" ofType:@"png"];
        UIImage *closeButtonItemImage =
        [[UIImage imageWithContentsOfFile:closeImgPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _webCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _webCloseButton.frame = CGRectMake(0, 0, 20, 44);
        [_webCloseButton setImage:closeButtonItemImage forState:UIControlStateNormal];
        [_webCloseButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_webCloseButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    return _webCloseButton;
}

- (UIButton *)titleButton {
    return [self webTitleButton];
}

- (UIView *)webView {
    return self.webViewComponent.ae_webView;
}

- (AEWebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[AEWebProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTintColor:SELF_NAV_BAR.tintColor];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    }
    return _progressView;
}

- (UIView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[UIView alloc] initWithFrame:self.view.bounds];
        _refreshView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WebViewRefreshFailUrl)];
        [_refreshView addGestureRecognizer:tapgesture];
        
        UIImage *refreshImage =  [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loadfail@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:refreshImage];
        imageView.center = _refreshView.center;
        [_refreshView addSubview:imageView];
        
        UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _refreshView.center.y + 36, _refreshView.frame.size.width, 50)];
        reminderLabel.text = @"页面加载失败，点击重新加载";
        reminderLabel.textColor = [UIColor grayColor];
        reminderLabel.font = [UIFont systemFontOfSize:15];
        reminderLabel.textAlignment = NSTextAlignmentCenter;
        [_refreshView addSubview:reminderLabel];
    }
    return _refreshView;
}



@end
