//
//  ZHWeiboManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHWeiboManager.h"
#import "ZHRequestTool.h"

static ZHWeiboManager *instance = nil;

static NSString *kWeiboUserInfoUrl = @"https://api.weibo.com/2/users/show.json";

@interface ZHWeiboManager ()

@property (nonatomic, copy) NSString *weiboAppKey;
@property (nonatomic, copy) NSString *weiboRedirectURI;
@property (nonatomic, copy) NSString *weiboToken;
@property (nonatomic, copy) NSString *weiboUserId;
@property (nonatomic, copy) NSString *weiboRefreshToken;
@property (nonatomic, copy) ZHThirdShareCallBack weiboShareCallBack;

@property (nonatomic, copy) ZHThirdLoginCallBack weiboLoginCallBack;

@end

@implementation ZHWeiboManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}


#pragma mark - singleton
+ (instancetype)manager
{
    return instance ? : [[self alloc] init];
}

#pragma mark - ZHThirdShareProtocol
- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI
{
    NSAssert(appKey, @"appKey cann't be nil");
    NSAssert(redirectURI, @"redirectURI cann't be nil");
    
    if ([WeiboSDK registerApp:appKey]) {
        self.weiboAppKey = appKey;
        self.weiboRedirectURI = redirectURI;
        [WeiboSDK enableDebugMode:YES];
    }
    else
    {
        ZHLog(@"registWeiboWithAppKey failed appKey = %@, redirectURI = %@", appKey, redirectURI);
    }
}

- (void)shareText:(NSString *)text callBack:(ZHThirdShareCallBack)callBack
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    if ([self shareToweiboWithMessage:message]) {
        self.weiboShareCallBack = callBack;
    }else
    {
        if (callBack) {
            callBack(@"发送错误", NO);
        }
    }
}

- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    
    if (image) {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = UIImageJPEGRepresentation(image, 1.0);
        if (imageObject.imageData.length > 10 * 1024 * 1024) {
            NSLog(@"image is bigger than 10M");
        }
        message.imageObject = imageObject;
    }
    
    if ([self shareToweiboWithMessage:message]) {
        self.weiboShareCallBack = callBack;
    }else
    {
        if (callBack) {
            callBack(@"发送错误", NO);
        }
    }
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = description;
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = title;
    webpage.description = description;
    NSData *imageData = UIImageJPEGRepresentation(thumbImage, 1.0);
    CGFloat rate = 0.9;
    while (imageData.length > 32 * 1024) {
        imageData = UIImageJPEGRepresentation(thumbImage, rate);
        rate -= 0.1;
    }
    webpage.thumbnailData = imageData;
    
    webpage.webpageUrl = urlStr;
    message.mediaObject = webpage;
    
    if ([self shareToweiboWithMessage:message]) {
        self.weiboShareCallBack = callBack;
    }else
    {
        if (callBack) {
            callBack(@"发送错误", NO);
        }
    }
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImageUrl:(NSString *)thumbImageUrl url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *imageUrl = [NSURL URLWithString:thumbImageUrl];
        NSData *data = nil;
        if (imageUrl) {
            data = [NSData dataWithContentsOfURL:imageUrl];
        }
        //回到主线程调用
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shareWebPageWithTitle:title description:description thumbImage:[UIImage imageWithData:data] url:urlStr callBack:callBack];
        });
    });
}

#pragma mark - ZHThirdLoginProtocol
- (void)loginWithCallBack:(ZHThirdLoginCallBack)callBack
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.weiboRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    if (![WeiboSDK sendRequest:request])
    {
        if (callBack) {
            callBack(nil, @"发送微博请求失败", NO);
        }
    }
    else
    {
        self.weiboLoginCallBack = callBack;
    }
}

#pragma mark - private method
- (BOOL)shareToweiboWithMessage:(WBMessageObject *)message
{
    NSAssert(self.weiboRedirectURI, @"weiboRedirectURI is nil, please call registWeiboWithAppKey:redirectURI: first");
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.weiboRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.weiboToken];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    return [WeiboSDK sendRequest:request];
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    //微博登陆
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        BOOL succeed = NO;
        NSString *message = nil;
        
        [self mapWeiboCode:response.statusCode toMessage:&message sucess:&succeed];
        if (self.weiboShareCallBack) {
            self.weiboShareCallBack(message, succeed);
            self.weiboShareCallBack = nil;
        }
        
        if (succeed) {
            [self getWeiboUserInfoWithUid:response.userInfo[@"uid"] accessToken:response.userInfo[@"access_token"]];
        }
        else
        {
            if (self.weiboLoginCallBack) {
                self.weiboLoginCallBack(nil, message, NO);
                self.weiboLoginCallBack = nil;
            }
        }
    }
    
    //微博分享
    else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.weiboToken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.weiboUserId = userID;
        }
        
        BOOL succeed = NO;
        NSString *message = nil;
        
        [self mapWeiboCode:response.statusCode toMessage:&message sucess:&succeed];
        if (self.weiboShareCallBack) {
            self.weiboShareCallBack(message, succeed);
            self.weiboShareCallBack = nil;
        }
    }
    else
    {
        if (self.weiboShareCallBack) {
            self.weiboShareCallBack(@"未识别的回应", NO);
        }
        if (self.weiboLoginCallBack) {
            self.weiboLoginCallBack(nil, @"未识别的回应", NO);
        }
        self.weiboShareCallBack = nil;
    }
}

#pragma mark - private method
- (void)mapWeiboCode:(NSInteger)statusCode toMessage:(NSString **)retMessage sucess:(BOOL *)retSucess
{
    BOOL succeed = NO;
    NSString *message = nil;
    switch (statusCode) {
        case WeiboSDKResponseStatusCodeSuccess:
            succeed = YES;
            message = @"操作成功";
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            succeed = NO;
            message = @"用户取消发送";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            succeed = NO;
            message = @"发送失败";
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            succeed = NO;
            message = @"授权失败";
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            succeed = NO;
            message = @"用户取消安装微博客户端";
            break;
        case WeiboSDKResponseStatusCodePayFail:
            succeed = NO;
            message = @"支付失败";
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
            succeed = NO;
            message = @"分享失败";
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
            succeed = NO;
            message = @"不支持的请求";
            break;
            
        default:
            succeed = NO;
            message = [NSString stringWithFormat:@"未知错误 code = %@", @(statusCode)];
            break;
    }
    
    if (retSucess) {
        *retSucess = succeed;
    }
    if (retMessage) {
        *retMessage = message;
    }
}

- (void)getWeiboUserInfoWithUid:(NSString *)uid accessToken:(NSString *)accessToken
{
    NSAssert(uid && accessToken, @"getWeiboUserInfo invalid uid = %@ and accessToken = %@", uid, accessToken);
    
    NSDictionary *param = @{@"access_token" : accessToken, @"uid" : uid};
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [ZHRequestTool GET:kWeiboUserInfoUrl parameters:param responseSerializer:ZHResponseSeriliserJSON requestResult:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //网络错误
        if (error) {
            if (self.weiboLoginCallBack) {
                self.weiboLoginCallBack(nil, @"获取失败, 请重试", NO);
                self.weiboLoginCallBack = nil;
            }
            return;
        }
        
        //获取成功
        if (responseObject[@"name"]) {
            if (self.weiboLoginCallBack) {
                ZHThirdUserInfo *userInfo = [[ZHThirdUserInfo alloc] init];
                userInfo.thirdSource = @"sina";
                userInfo.name = responseObject[@"name"];
                userInfo.uid = uid;
                userInfo.accessToken = accessToken;
                userInfo.imageUrl = responseObject[@"avatar_hd"];
                userInfo.expiresDate = [NSDate date];
                self.weiboLoginCallBack(userInfo, @"获取微博用户信息成功", YES);
            }
        }
        else
        {
            if (self.weiboLoginCallBack) {
                self.weiboLoginCallBack(responseObject, @"获取微博用户信息失败", NO);
            }
        }
        self.weiboLoginCallBack = nil;
        
        
    }];
}

@end
