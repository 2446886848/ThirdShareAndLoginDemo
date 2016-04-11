//
//  ZHThirdManager.h
//  ZHThirdPlatformDemo
//
//  Created by 吴志和 on 16/1/23.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHThirdProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHThirdManager : NSObject

+ (instancetype)manager;

#pragma mark - third share
- (void)registerThirdPlatform:(ZHThirdType)thirdType appKey:(NSString *)appKey secret:(nullable NSString *)secret redirectURI:(nullable NSString *)redirectURI;

- (void)shareTextToThird:(ZHThirdType)thirdType text:(NSString *)text callBack:(ZHThirdShareCallBack)callBack;

- (void)shareTextToThird:(ZHThirdType)thirdType text:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack;

- (void)shareWebPageToThird:(ZHThirdType)thirdType title:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack;

#pragma mark - third login

- (void)getThirdUserInfo:(ZHThirdType)thirdType callBack:(ZHThirdLoginCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
