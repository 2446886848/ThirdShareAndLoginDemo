//
//  ZHQQBase.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHQQBase.h"
#import "ZHRequestTool.h"

static NSString *const kQQGetUserInfoUrl = @"https://graph.qq.com/user/get_user_info";

@implementation ZHQQBase

#pragma mark - public method
- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI
{
    self.oauth = [[TencentOAuth alloc] initWithAppId:appKey
                                         andDelegate:self];
    if (self.oauth) {
        self.appKey = appKey;
    }
}

- (void)shareWithContentObject:(QQApiObject *)object
{
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    NSString *message = nil;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            message = @"App未注册";
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            message = @"发送参数错误";
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            message = @"未安装手Q";
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            message = @"API接口不支持";
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            message = @"发送失败";
            
            break;
        }
        default:
        {
            break;
        }
    }
    if (message && self.shareCallBack) {
        self.shareCallBack(message, NO);
        self.shareCallBack = nil;
    }
}

#pragma mark - TencentSessionDelegate
- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
    ZHDebugMethod();
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    ZHDebugMethod();
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin
{
    NSDictionary *param = @{@"access_token" : self.oauth.accessToken, @"openid" : self.oauth.openId, @"oauth_consumer_key" : self.appKey};
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [ZHRequestTool GET:kQQGetUserInfoUrl parameters:param responseSerializer:ZHResponseSeriliserHTTP requestResult:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //网络错误
        if (error) {
            if (self.loginCallBack) {
                self.loginCallBack(nil, error.localizedDescription, NO);
                self.loginCallBack = nil;
            }
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            if (self.loginCallBack) {
                self.loginCallBack(nil, jsonError.localizedDescription, NO);
                self.loginCallBack = nil;
            }
            return;
        }
        
        //获取成功
        if(dic[@"nickname"])
        {
            if (self.loginCallBack) {
                ZHThirdUserInfo *userInfo = [[ZHThirdUserInfo alloc] init];
                userInfo.thirdSource = @"qq";
                userInfo.name = dic[@"nickname"];
                userInfo.uid = self.oauth.openId;
                userInfo.accessToken = self.oauth.accessToken;
                userInfo.imageUrl = dic[@"figureurl_qq_1"];
                userInfo.expiresDate = self.oauth.expirationDate;
                
                self.loginCallBack(userInfo, @"获取QQ用户信息成功", YES);
                self.loginCallBack = nil;
            }
        }
        else{
            if (self.loginCallBack) {
                self.loginCallBack(nil, dic[@"msg"], NO);
                self.loginCallBack = nil;
            }
        }
    }];
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        if (self.loginCallBack) {
            self.loginCallBack(nil, @"用户取消登录", NO);
        }
    }
    else
    {
        if (self.loginCallBack) {
            self.loginCallBack(nil, @"登录失败", NO);
        }
    }
    self.loginCallBack = nil;
}

-(void)tencentDidNotNetWork
{
    if (self.loginCallBack) {
        self.loginCallBack(nil, @"无网络连接，请设置网络", NO);
    }
    self.loginCallBack = nil;
}

#pragma mark - QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req
{
    
}

- (void)onResp:(QQBaseResp *)resp
{
    if (resp.type == ESENDMESSAGETOQQRESPTYPE) {
        NSString *message = nil;
        BOOL sucess = NO;
        NSInteger result = [resp.result integerValue];
        
        switch (result) {
            case 0:
                message = @"分享成功";
                sucess = YES;
                break;
            case -4:
                message = @"用户取消";
                sucess = NO;
                break;
                
            default:
                message = @"分享失败";
                sucess = NO;
                break;
        }
        
        if (self.shareCallBack) {
            self.shareCallBack(message, sucess);
            self.shareCallBack = nil;
        }
    }
    else
    {
        
    }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
    ZHDebugMethod();
}

@end
