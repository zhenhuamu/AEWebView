//
//  AEWebViewNavigationBar.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebViewNavigationBar.h"

#define kRightButtonTag 1000
#define kLeftButtonTag 1001

@implementation AEWebViewNavigationBar

+ (instancetype)navigationBar {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect barFrame = CGRectMake(0, 0, width, 64);
    AEWebViewNavigationBar *bar = [[AEWebViewNavigationBar alloc] initWithFrame:barFrame];
    bar.backgroundColor = [UIColor whiteColor];
    // 默认有一个返回按钮
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *backButtonItemImage = [[UIImage imageWithContentsOfFile:[[NSBundle hj_webViewBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [backButton setImage:backButtonItemImage forState:UIControlStateNormal];
//    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    backButton.frame = CGRectMake(10, kHJWebViewIsiPhoneXSeries ? 44 : 20, 44, 44);
//    [bar addSubview:backButton];
//    
//    bar.backButton = backButton;
//    
//    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [titleButton setTitle:@"" forState:UIControlStateNormal];
//    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
//    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleButton.frame = CGRectMake((width - 100) * 0.5, kHJWebViewIsiPhoneXSeries ? 44 : 20, 100, 44);
//    [bar addSubview:titleButton];
//    
//    bar.titleButton = titleButton;
//    
//    [bar setUpConstraint];
    
    return bar;
}

- (void)setUpConstraint {
    
//    [_titleButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:_titleButton
//                                                                         attribute:NSLayoutAttributeCenterX
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self
//                                                                         attribute:NSLayoutAttributeCenterX
//                                                                        multiplier:1
//                                                                          constant:0];
//
//    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:_titleButton
//                                                                         attribute:NSLayoutAttributeCenterY
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self
//                                                                         attribute:NSLayoutAttributeCenterY
//                                                                        multiplier:1
//                                                                          constant:(kHJWebViewIsiPhoneXSeries ? 22 : 10)];
//
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_titleButton
//                                                                       attribute:NSLayoutAttributeWidth
//                                                                       relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                          toItem:nil
//                                                                       attribute:NSLayoutAttributeWidth
//                                                                      multiplier:1
//                                                                        constant:HJWEB_SWIDTH - 100];
//
//    yCenterConstraint.priority = UILayoutPriorityDefaultLow;
//    xCenterConstraint.priority = UILayoutPriorityDefaultLow;
//    widthConstraint.priority = UILayoutPriorityDefaultLow;
//
//    [self addConstraint:yCenterConstraint];
//    [self addConstraint:xCenterConstraint];
//    [self addConstraint:widthConstraint];
}

- (void)setLeftButtons:(NSArray<UIButton *> *)buttons {
    
//    for (UIView *subView in self.subviews) {
//        if (subView.tag == kLeftButtonTag) {
//            [subView removeFromSuperview];
//        }
//    }
//
//    if (buttons.count <= 0) {
//        return ;
//    }
//
//    [self.backButton removeFromSuperview];
//
//    CGFloat currentX = 16;
//
//    for (int i = 0 ; i < buttons.count ; i ++) {
//
//        UIButton *button = buttons[i];
//
//        button.tag = kLeftButtonTag;
//
//        CGFloat y =  (44 - button.frame.size.height) * 0.5 + (kHJWebViewIsiPhoneXSeries ? 44 : 20);
//
//        CGRect frame = CGRectMake(currentX,
//                                  y,
//                                  button.frame.size.width,
//                                  button.frame.size.height);
//        button.frame = frame;
//
//        [self addSubview:button];
//
//        // 加上 10 的宽度间隙
//        currentX += button.frame.size.width + 10;
//    }
}

- (void)setRightButtons:(NSArray<UIButton *> *)buttons {
    
//    for (UIView *subView in self.subviews) {
//        if (subView.tag == kRightButtonTag) {
//            [subView removeFromSuperview];
//        }
//    }
//
//    if (buttons.count <= 0) {
//        return ;
//    }
//
//    CGFloat currentX = 16;
//
//    for (int i = 0 ; i < buttons.count ; i ++) {
//
//        UIButton *button = buttons[i];
//
//        button.tag = kRightButtonTag;
//
//        CGFloat y =  (44 - button.frame.size.height) * 0.5 + (kHJWebViewIsiPhoneXSeries ? 44 : 20);
//
//        CGFloat x = self.frame.size.width - currentX - button.frame.size.width;
//
//        CGRect frame = CGRectMake(x,
//                                  y,
//                                  button.frame.size.width,
//                                  button.frame.size.height);
//        button.frame = frame;
//
//        // 加上 10 的宽度间隙
//        currentX += button.frame.size.width + 10;
//
//        [self addSubview:button];
//    }
}


@end
