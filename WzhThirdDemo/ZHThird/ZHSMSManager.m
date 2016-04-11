//
//  ZHSMSManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHSMSManager.h"

#import <MessageUI/MessageUI.h>

static ZHSMSManager *instance = nil;

@interface ZHSMSManager ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, copy) ZHThirdShareCallBack callBack;

@end

@implementation ZHSMSManager

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
    self.callBack = callBack;
    [self sendSMSWithText:text];
}
- (void)shareText:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    self.callBack = callBack;
    [self sendSMSWithText:text];
}
- (void)shareWebPageWithTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    self.callBack = callBack;
    [self sendSMSWithText:urlStr];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{}];
    NSString *message = nil;
    BOOL sucess = NO;
    switch (result) {
        case MessageComposeResultCancelled:
            message = @"用户取消";
            sucess = NO;
            break;
        case MessageComposeResultSent:
            message = @"发送成功";
            sucess = YES;
            break;
        case MessageComposeResultFailed:
            message = @"发送失败";
            sucess = NO;
            break;
            
        default:
            break;
    }
    
    if (self.callBack) {
        self.callBack(message, sucess);
    }
}

#pragma mark - private method

- (void)sendSMSWithText:(NSString *)text
{
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
    messageVC.messageComposeDelegate = self;
    if (![MFMessageComposeViewController canSendText]) {
        if (self.callBack) {
            self.callBack(@"无法发送", NO);
            return;
        }
    }
    messageVC.body = text;
    [[self zh_topMostViewController] presentViewController:messageVC animated:YES completion:^{
    }];
}

- (UIViewController *)zh_topMostViewController
{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    if (![NSStringFromClass([rootWindow class]) isEqualToString:@"UIWindow"]) {
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if ([NSStringFromClass([window class]) isEqualToString:@"UIWindow"]) {
                rootWindow = window;
                break;
            }
        }
    }
    
    UIViewController *viewController = rootWindow.rootViewController;
    
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarViewcontroller = (UITabBarController *)viewController;
            if (tabBarViewcontroller.viewControllers.count > 0) {
                viewController = tabBarViewcontroller.viewControllers[tabBarViewcontroller.selectedIndex];
                continue;
            }
            else
            {
                return tabBarViewcontroller;
            }
        }
        else if([viewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navigationcontroller = (UINavigationController *)viewController;
            if (navigationcontroller.viewControllers.count > 0) {
                viewController = navigationcontroller.topViewController;
                continue;
            }
            else
            {
                return navigationcontroller;
            }
        }
        else if([viewController isKindOfClass:[UIViewController class]])
        {
            if (viewController.presentedViewController) {
                viewController = viewController.presentedViewController;
                continue;
            }
            else
            {
                return viewController;
            }
        }
        else
        {
            return nil;
        }
    }
    return viewController;
}

@end
