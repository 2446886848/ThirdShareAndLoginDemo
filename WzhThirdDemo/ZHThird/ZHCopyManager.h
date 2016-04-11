//
//  ZHCopyManager.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHThirdProtocol.h"

@interface ZHCopyManager : NSObject<ZHThirdShareProtocol>

+ (instancetype)manager;

@end
