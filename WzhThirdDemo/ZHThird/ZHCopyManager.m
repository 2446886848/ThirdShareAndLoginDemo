//
//  ZHCopyManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHCopyManager.h"

static ZHCopyManager *instance = nil;

@interface ZHCopyManager ()

@end

@implementation ZHCopyManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)manager
{
    return instance ? : [[self alloc] init];
}

#pragma mark - ZHThirdShareProtocol

- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI
{
}
- (void)shareText:(NSString *)text callBack:(ZHThirdShareCallBack)callBack
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    callBack(@"复制成功", YES);
}
- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.image = image;
    callBack(@"复制成功", YES);
}
- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = urlStr;
    callBack(@"复制成功", YES);
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImageUrl:(NSString *)thumbImageUrl url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    [self shareWebPageWithTitle:title description:description thumbImage:nil url:urlStr callBack:callBack];
}
@end
