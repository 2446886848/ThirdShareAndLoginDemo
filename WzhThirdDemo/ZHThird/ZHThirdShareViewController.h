//
//  ZHThirdShareViewController.h
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHThirdProtocol.h"

typedef NS_ENUM(NSUInteger, ZHThirdShareType) {
    ZHThirdShareTypeNone = 300,
    ZHThirdShareTypeText,
    ZHThirdShareTypeImage,
    ZHThirdShareTypeWebPage,
};

typedef void(^ThirdShareWindowCallBack)(ZHThirdType thirdType);

@interface ZHThirdShareViewController : UIViewController

- (instancetype)initWithSharedType:(ZHThirdShareType)thirdSharedType callBack:(ThirdShareWindowCallBack)callBack;

@end
