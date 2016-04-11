//
//  ZHWeixinManager.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHWeixinBase.h"

@interface ZHWeixinManager : ZHWeixinBase<ZHThirdLoginProtocol>

+ (instancetype)manager;

@end
