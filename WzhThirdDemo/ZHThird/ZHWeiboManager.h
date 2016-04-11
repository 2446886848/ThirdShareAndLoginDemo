//
//  ZHWeiboManager.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeiboSDK.h"
#import "ZHThirdProtocol.h"

@interface ZHWeiboManager : NSObject<ZHThirdShareProtocol, WeiboSDKDelegate, ZHThirdLoginProtocol>

+ (instancetype)manager;

@end
