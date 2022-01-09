//
//  AEWebBaseComponent.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebBaseComponent.h"

@implementation AEWebBaseComponent

- (instancetype)init {
    if (self = [super init]) {
        self.ae_updateTitle = AEWEB_EMPTY_BLOCK;
        self.ae_updateLeftBarButtonItems = AEWEB_EMPTY_BLOCK;
        self.ae_updateRightBarButtonItems= AEWEB_EMPTY_BLOCK;
        self.ae_addRefreshView = AEWEB_EMPTY_BLOCK;
        self.ae_removeRefreshView = AEWEB_EMPTY_BLOCK;
        self.ae_startProgress = AEWEB_EMPTY_BLOCK;
        self.ae_endProgress = AEWEB_EMPTY_BLOCK;
        self.ae_updateProgress = ^(CGFloat value){};
    }
    return self;
}

- (void)ae_backAction:(id)sender {
}

- (BOOL)ae_canGoBack {
    return NO;
}

- (void)ae_dealloc {
}

- (void)ae_loadHTMLString:(NSString *)URLString {
}

- (void)ae_loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl {
}

- (void)ae_loadRequest:(NSURLRequest *)request {
}

- (void)ae_updateTitle:(UIButton *)titleButton showUrl:(BOOL)showUrl showsPageTitle:(BOOL)showsPageTitle {
}

- (void)ae_viewDidLoadWithNav:(BOOL)navigationController superView:(UIView *)superView {
}

- (void)ae_viewWillAppear:(BOOL)animated {
}

- (void)ae_goBack {
}

- (void)ae_failUrlRefresh {
}

- (NSInteger)ae_goBackPageCount {
    return 0;
}

- (UIView *)ae_webView {
    return nil;
}

- (void)ae_resetWebView {
}


@end
