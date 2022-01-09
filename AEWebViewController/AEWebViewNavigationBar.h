//
//  AEWebViewNavigationBar.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEWebViewNavigationBar : UIView

/// 导航栏初始化
+ (instancetype)navigationBar;

/// 设置导航栏右边按钮
- (void)setRightButtons:(NSArray <UIButton *> *)buttons;

/// 设置导航栏左边按钮
- (void)setLeftButtons:(NSArray <UIButton *> *)buttons;

/// 标题按钮
@property (strong, nonatomic) UIButton *titleButton;

/// 返回按钮
@property (strong, nonatomic) UIButton *backButton;


@end

NS_ASSUME_NONNULL_END
