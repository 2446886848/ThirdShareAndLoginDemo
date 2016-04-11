//
//  ZHWeixinBase.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHWeixinBase.h"
#import "ZHRequestTool.h"

static NSString *const kWeixinLoginState = @"kWeixinLoginState";
static NSString *const kWeixinGetAccessTokenUrl = @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code";
static NSString *const kWeixinGetUserInfoUrl = @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@";

@interface ZHWeixinBase ()

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, copy) ZHThirdShareCallBack weixinShareCallBack;

@property (nonatomic, copy) ZHThirdLoginCallBack weixinLoginCallBack;

@end

@implementation ZHWeixinBase

#pragma mark - ZHThirdShareProtocol
- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI
{
    if ([WXApi registerApp:appKey]) {
        self.appKey = appKey;
        self.appSecret = secret;
    }
}

- (void)shareText:(NSString *)text callBack:(ZHThirdShareCallBack)callBack
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = text;
    req.bText = YES;
    req.scene = self.scene;
    
    if ([WXApi sendReq:req])
    {
        self.weixinShareCallBack = callBack;
    }
    else
    {
        if (callBack) {
            callBack(@"发送失败", NO);
        }
    }
}

- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [message setThumbImage:[self thumbImageWithImage:image destSize:32 * 1024]];
    
    WXImageObject *ext = [WXImageObject object];
    
    //大小不能超过10M
    ext.imageData = imageData;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = self.scene;
    
    if ([WXApi sendReq:req])
    {
        self.weixinShareCallBack = callBack;
    }
    else
    {
        if (callBack) {
            callBack(@"发送失败", NO);
        }
    }
}

- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlStr;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = self.scene;
    
    if ([WXApi sendReq:req])
    {
        self.weixinShareCallBack = callBack;
    }
    else
    {
        if (callBack) {
            callBack(@"发送失败", NO);
        }
    }
}

#pragma mark - ZHThirdLoginProtocol
- (void)loginWithCallBack:(ZHThirdLoginCallBack)callBack
{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = kWeixinLoginState;
    if ([WXApi sendReq:req]) {
        self.weixinLoginCallBack = callBack;
    }
    else
    {
        callBack(nil, @"发送请求失败", NO);
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp*)resp
{
    NSString *message = nil;
    BOOL succees = NO;
    if (resp.type == 0) {
        switch (resp.errCode) {
            case WXSuccess:
                message = @"发送成功";
                succees = YES;
                break;
            case WXErrCodeCommon:
                message = @"发送失败";
                succees = NO;
                break;
            case WXErrCodeUserCancel:
                message = @"用户取消";
                succees = NO;
                break;
            case WXErrCodeSentFail:
                message = @"发送失败";
                succees = NO;
                break;
            case WXErrCodeAuthDeny:
                message = @"授权失败";
                succees = NO;
                break;
            case WXErrCodeUnsupport:
                message = @"微信不支持";
                succees = NO;
                break;
                
            default:
                break;
        }
    }
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        
        if ([authResp.state isEqualToString:kWeixinLoginState]) {
            [self getWeixinAccessTokenWithCode:authResp.code];
        }
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (self.weixinShareCallBack) {
            self.weixinShareCallBack(message, succees);
            self.weixinShareCallBack = nil;
        }
    }
}

#pragma mark - private method

- (void)getWeixinAccessTokenWithCode:(NSString *)code
{
    NSAssert(code && self.appKey && self.appSecret, @"invalid param code = %@ appkey = %@ secret = %@", code, self.appKey, self.appSecret);
    
    NSString *url =[NSString stringWithFormat:kWeixinGetAccessTokenUrl,self.appKey,self.appSecret,code];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [ZHRequestTool GET:url requestResult:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //网络错误
        if (error) {
            if (self.weixinLoginCallBack) {
                self.weixinLoginCallBack(nil, error.localizedDescription, NO);
                self.weixinLoginCallBack = nil;
            }
            return;
        }
        
        //获取成功
        
        NSError *jsonError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            if (self.weixinLoginCallBack) {
                self.weixinLoginCallBack(nil, jsonError.localizedDescription, NO);
                self.weixinLoginCallBack = nil;
            }
        }
        else
        {
            if (dic[@"access_token"]) {
                [self getWeixinUserInfoWithUid:dic[@"openid"] accessToken:dic[@"access_token"]];
            }
            else
            {
                if (self.weixinLoginCallBack) {
                    self.weixinLoginCallBack(nil, @"无法获取微信access_token数据", NO);
                    self.weixinLoginCallBack = nil;
                }
            }
        }
    }];
}

- (void)getWeixinUserInfoWithUid:(NSString *)uid accessToken:(NSString *)accessToken
{
    NSString *url =[NSString stringWithFormat:kWeixinGetUserInfoUrl, accessToken, uid];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [ZHRequestTool GET:url requestResult:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //网络错误
        if (error) {
            if (self.weixinLoginCallBack) {
                self.weixinLoginCallBack(nil, error.localizedDescription, NO);
                self.weixinLoginCallBack = nil;
            }
            return;
        }
        //获取成功
        
        NSError *jsonError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            if (self.weixinLoginCallBack) {
                self.weixinLoginCallBack(nil, jsonError.localizedDescription, NO);
                self.weixinLoginCallBack = nil;
            }
        }
        else
        {
            if (dic[@"openid"]) {
                if (self.weixinLoginCallBack) {
                    ZHThirdUserInfo *userInfo = [[ZHThirdUserInfo alloc] init];
                    userInfo.thirdSource = @"weixin";
                    userInfo.name = dic[@"nickname"];
                    userInfo.uid = uid;
                    userInfo.accessToken = accessToken;
                    userInfo.imageUrl = dic[@"headimgurl"];
                    userInfo.expiresDate = [NSDate date];
                    
                    self.weixinLoginCallBack(userInfo, @"获取微信用户信息成功", YES);
                    self.weixinLoginCallBack = nil;
                }
            }
            else
            {
                if (self.weixinLoginCallBack) {
                    self.weixinLoginCallBack(nil, [NSString stringWithFormat:@"获取微信信息失败，errcode:%@", dic[@"ret"]], NO);
                    self.weixinLoginCallBack = nil;
                }
            }
        }
        
    }];
}

- (UIImage *)thumbImageWithImage:(UIImage *)image destSize:(NSInteger)destSize
{
    destSize *= 2;
    NSData *pngData = UIImageJPEGRepresentation(image, 1.0);
    
    if (pngData.length < destSize) {
        return image;
    }
    
    CGFloat scale = destSize * 1.0 / pngData.length;
    
    CGFloat destWidth = image.size.width * scale;
    CGFloat destHeight = image.size.height * scale;
    UIGraphicsBeginImageContext(CGSizeMake(destWidth, destHeight));
    [image drawInRect:CGRectMake(0, 0, destWidth, destHeight)];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}

@end
