//
//  ZHThirdSharewindow.m
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHThirdSharewindow.h"
#import "ZHThirdShareViewController.h"

@implementation ZHThirdShareWindow

static UIWindow *window;

+ (void)showWithType:(ZHThirdShareType)thirdSharedType callBack:(ThirdShareWindowCallBack)callBack
{
    window = [[UIWindow alloc] init];
    window.frame = [UIScreen mainScreen].bounds;
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = NO;
    window.rootViewController = [[ZHThirdShareViewController alloc] initWithSharedType:thirdSharedType callBack:callBack];
    window.backgroundColor = [UIColor clearColor];
}

+ (void)hide
{
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
        window.alpha = 0;
    } completion:^(BOOL finished) {
        window = nil;
    }];
}

@end
