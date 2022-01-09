//
//  AEWebViewController_Define.h
//  Ahaearth
//
//  Created by AndyMu on 2021/6/27.
//  Copyright © 2021 ahaearth. All rights reserved.
//

#ifndef AEWebViewController_Define_h
#define AEWebViewController_Define_h

typedef NSString* AEWebString;

typedef void (^AEWebViewAction) (void);

typedef void (^AEWebViewRefreshProgressValue) (CGFloat value);

static AEWebString const Kaeweb_URL = @"URL";

static AEWebString const Kaeweb_estimatedProgress = @"estimatedProgress";

#define AEWEB_EMPTY_BLOCK ^{}

// 弱引用
#define AEWEB_WEAK_SELF __weak typeof(self)weakSelf = self;
#define AEWEB_STRONG_SELF __strong typeof(weakSelf)self = weakSelf;

#define AEWebObjIsNilOrNull(_obj)    (((_obj) == nil) || (_obj == (id)kCFNull))
#define AEWebStrIsEmpty(_str)        (AEWebObjIsNilOrNull(_str) || (![(_str) isKindOfClass:[NSString class]]) || ([(_str) isEqualToString:@""]))


#endif /* AEWebViewController_Define_h */
