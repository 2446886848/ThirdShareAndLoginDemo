//
//  ZHThirdProtocol.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#ifndef ZHThirdProtocol_h
#define ZHThirdProtocol_h

#import <UIKit/UIKit.h>

#import "ZHThirdUserInfo.h"

static const CGFloat kGetUserInfoTimeOut = 10.0;

typedef NS_ENUM(NSUInteger, ZHThirdType) {
    ZHThirdTypeNone = 250,
    ZHThirdTypeWeibo,
    ZHThirdTypeQQ,
    ZHThirdTypeQQSpace,
    ZHThirdTypeWeixin,
    ZHThirdTypeWeixinSpace,
    ZHThirdTypeSMS,
    ZHThirdTypeCopy,
};

typedef void(^ZHThirdShareCallBack)(NSString *message, BOOL succeed);

typedef void(^ZHThirdLoginCallBack)(ZHThirdUserInfo *userInfo, NSString *message, BOOL succeed);

@protocol ZHThirdShareProtocol <NSObject>

@optional
- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI;
- (void)shareText:(NSString *)text callBack:(ZHThirdShareCallBack)callBack;
- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack;
- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack;
- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImageUrl:(NSString *)thumbImageUrl url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack;

@end

@protocol ZHThirdLoginProtocol <NSObject>

@required
- (void)loginWithCallBack:(ZHThirdLoginCallBack)callBack;

@end

#endif /* ZHThirdProtocol_h */
