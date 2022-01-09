//
//  AEHandleMacros.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#ifndef AEHandleMacros_h
#define AEHandleMacros_h

#pragma mark - js -> native

/// 获取app版本
static NSString * const kAppGetVersion = @"appGetVersion";

/// 获取bundleID
static NSString * const kAppGetBundleId = @"appGetBundleId";

/// 获取设备类型 (iOS/Android)
static NSString * const kAppGetDeviceType = @"appGetDeviceType";

/// 页面返回
static NSString * const kAppExecClose = @"appExecClose";

#pragma mark - native -> js

/// 页面加载
static NSString * const kWebViewDidLoad = @"webViewDidLoad";

/// 页面将要显示
static NSString * const kWebViewWillAppear = @"webViewWillAppear";

/// 页面已经显示
static NSString * const kWebViewDidAppear = @"webViewDidAppear";

/// 页面将要消失
static NSString * const kWebViewWillDisappear = @"webViewWillDisappear";

/// 页面已经消失
static NSString * const kWebViewDidDisappear = @"webViewDidDisappear";

#endif /* AEHandleMacros_h */
