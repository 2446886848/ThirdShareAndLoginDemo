//
//  ZHQQManager.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHQQBase.h"

#import "ZHThirdProtocol.h"

@interface ZHQQManager : ZHQQBase<ZHThirdShareProtocol, ZHThirdLoginProtocol>

+ (instancetype)manager;

@end
