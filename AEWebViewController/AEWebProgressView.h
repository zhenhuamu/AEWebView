//
//  AEWebProgressView.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEWebProgressView : UIProgressView

/// 到达伪目标的时间 默认 1秒
@property (assign, nonatomic) NSTimeInterval fakeDuration;

/// 到达伪目标的次数 默认 3次
@property (assign, nonatomic) NSInteger fakeCount;

/// 伪目标百分比 默认 0.96
@property (assign, nonatomic) CGFloat fakeProgress;

/// 开始加载数据
- (void)start;

/// 结束加载数据
- (void)endWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
