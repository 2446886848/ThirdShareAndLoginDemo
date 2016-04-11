//
//  ZHThirdShareWindow.h
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHThirdShareViewController.h"

@interface ZHThirdShareWindow : UIWindow

+ (void)showWithType:(ZHThirdShareType)thirdSharedType callBack:(ThirdShareWindowCallBack)callBack;

+ (void)hide;

@end
