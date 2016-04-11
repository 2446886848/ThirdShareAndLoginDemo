//
//  ZHQQManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHQQManager.h"

static ZHQQManager *instance = nil;

@interface ZHQQManager ()

@end

@implementation ZHQQManager

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
    self.shareCallBack = callBack;
    QQApiTextObject *textObj = [QQApiTextObject objectWithText:text];
    [self shareWithContentObject:textObj];
}

- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    NSAssert(image, @"image cann't be nil");
    if (!self.oauth || !image) {
        if (callBack) {
            callBack(@"please call registerWithAppKey first", NO);
        }
        return;
    }
    
    self.shareCallBack = callBack;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imageData
                                               previewImageData:imageData
                                                          title:@"title"
                                                   description :text];
    [self shareWithContentObject:imgObj];
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    self.shareCallBack = callBack;
    
    QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlStr] title:title description:description previewImageData:UIImageJPEGRepresentation(thumbImage, 1.0)];
    [self shareWithContentObject:newsObject];
}

#pragma mark - ZHThirdLoginProtocol
- (void)loginWithCallBack:(ZHThirdLoginCallBack)callBack
{
    self.loginCallBack = callBack;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    if (!self.oauth) {
        callBack(nil, @"应用未注册", NO);
    }
    else
    {
        [self.oauth authorize:permissions inSafari:NO];
    }
}

@end
