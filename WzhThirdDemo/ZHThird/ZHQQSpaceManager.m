//
//  ZHQQSpaceManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHQQSpaceManager.h"

static ZHQQSpaceManager *instance = nil;

@implementation ZHQQSpaceManager

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

- (void)shareText:(NSString *)text callBack:(ZHThirdShareCallBack)callBack
{
    if (callBack) {
        callBack(@"不支持的分享", NO);
    }
}

- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    if (callBack) {
        callBack(@"不支持的分享", NO);
    }
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    self.shareCallBack = callBack;
    
    QQApiNewsObject* newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlStr] title:title description:description previewImageData:UIImageJPEGRepresentation(thumbImage, 1.0)];
    
    [newsObject setCflag: kQQAPICtrlFlagQZoneShareOnStart ];
    [self shareWithContentObject:newsObject];
}

@end
