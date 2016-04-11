//
//  ViewController.m
//  WzhThirdDemo
//
//  Created by 吴志和 on 16/4/11.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import "ViewController.h"
#import "ZHShareManager.h"
#import "ZHThirdManager.h"

static NSString *const kTencentDemoAppid = @"222222";
static NSString *const kWeixinAppId = @"wxd930ea5d5a258f4f";
static NSString *const kWeiboAppId = @"3562316345";
static NSString *const kWeiboAppSecret = @"038f0be88c9c6197c56e3a904229f37d";
static NSString *const kWeiboRedirectURI = @"http://www.baidu.com";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //统一注册三个平台的appkey信息
    [[ZHThirdManager manager] registerThirdPlatform:ZHThirdTypeQQ appKey:kTencentDemoAppid secret:nil redirectURI:nil];
    [[ZHThirdManager manager] registerThirdPlatform:ZHThirdTypeWeixin appKey:kWeixinAppId secret:nil redirectURI:nil];
    [[ZHThirdManager manager] registerThirdPlatform:ZHThirdTypeWeibo appKey:kWeiboAppId secret:kWeiboAppSecret redirectURI:kWeiboRedirectURI];
}

/**
 *  分享文字
 */
- (IBAction)shareText:(id)sender {
    [ZHShareManager shareWithSharedType:ZHThirdShareTypeText title:@"要分享的文字" image:nil url:nil description:nil weiboDescription:nil callBack:^(NSString *message, BOOL succeed) {
        ZHLog(@"分享文字结果successd:%@\t message:%@", @(succeed), message);
    }];
}

/**
 *  分享图片
 */
- (IBAction)sharePicture:(id)sender {
    [ZHShareManager shareWithSharedType:ZHThirdShareTypeImage title:@"要分享的文字" image:[UIImage imageNamed:@"copy_link"] url:nil description:nil weiboDescription:nil callBack:^(NSString *message, BOOL succeed) {
        ZHLog(@"分享图片结果successd:%@\t message:%@", @(succeed), message);
    }];
}

/**
 *  分享网页
 */
- (IBAction)shareWebPage:(id)sender {
    [ZHShareManager shareWithSharedType:ZHThirdShareTypeWebPage title:@"要分享的标题" image:[UIImage imageNamed:@"copy_link"] url:@"https://www.baidu.com" description:@"要分享的描述" weiboDescription:@"微博要分享的描述" callBack:^(NSString *message, BOOL succeed) {
        ZHLog(@"分享网页结果successd:%@\t message:%@", @(succeed), message);
    }];
}

/**
 *  QQ登录
 */
- (IBAction)QQLogin:(id)sender {
    [[ZHThirdManager manager] getThirdUserInfo:ZHThirdTypeQQ callBack:^(ZHThirdUserInfo *userInfo, NSString *message, BOOL succeed){
        ZHLog(@"QQLogin succeed = %@, userInfo = %@", @(succeed), userInfo);
    }];
}

/**
 *  微信登录
 */
- (IBAction)weixinLogin:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"由于没有得到微信“SDKSample”对应的APPSecret，因此无法测试登录功能,需要测试请替换为自己的APPKey和APPsecret" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
    return;
    
#warning 以下为测试微信登录的代码
    [[ZHThirdManager manager] getThirdUserInfo:ZHThirdTypeWeixin callBack:^(ZHThirdUserInfo *userInfo, NSString *message, BOOL succeed){
        ZHLog(@"weixinLogin succeed = %@, userInfo = %@", @(succeed), userInfo);
    }];
}

/**
 *  微博登录
 */
- (IBAction)weiboLogin:(id)sender {
    [[ZHThirdManager manager] getThirdUserInfo:ZHThirdTypeWeibo callBack:^(ZHThirdUserInfo *userInfo, NSString *message, BOOL succeed){
        ZHLog(@"weiboLogin succeed = %@, userInfo = %@", @(succeed), userInfo);
    }];
}

@end
