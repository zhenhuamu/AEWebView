//
//  AEWebProgressView.m
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#import "AEWebProgressView.h"

@interface AEWebProgressView()

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger currentFake;

@end

@implementation AEWebProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.fakeCount = 3;
        self.fakeDuration = 1;
        self.fakeProgress = 0.96;
        self.currentFake = 0;
    }
    return self;
}

#pragma mark - Public Method

- (void)start {
    [self setAlpha:1.0f];
    [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(progressRaise)
                                                   object:nil];
    [super setProgress:0.0f animated:NO];
    self.currentFake = 0;
    [self startTimer];
}

- (void)endWithAnimated:(BOOL)animated {
    [self setProgress:1.0 animated:animated];
}

#pragma mark - Private Method

- (void)startTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    CGFloat perDuration = self.fakeDuration / self.fakeCount;
    _timer = [NSTimer scheduledTimerWithTimeInterval:perDuration
                                              target:self
                                            selector:@selector(progressRaise)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)progressRaise {
    self.currentFake ++;
    if (self.currentFake > self.fakeCount) {
        return ;
    }
    CGFloat perFakeProgress = self.fakeProgress / self.fakeCount;
    CGFloat currentFakeProgress = self.currentFake * perFakeProgress;
    if (self.progress < currentFakeProgress) {
        [self setProgress:currentFakeProgress animated:YES];
    }
}

#pragma mark - Super Method

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress < self.progress) {
        return ;
    }
    self.alpha = 1.0f;
    [super setProgress:progress animated:animated];
    if (progress >= 1.0f) {
        if (_timer) {
            [_timer invalidate];
        }
        [UIView animateWithDuration:0.3f
                              delay:0.5f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [super setProgress:0.0f animated:NO];
                         }];
    }
}

@end
