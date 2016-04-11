//
//  ZHThirdUserInfo.m
//  Tianji
//
//  Created by 吴志和 on 16/1/26.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHThirdUserInfo.h"

@implementation ZHThirdUserInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n{\n\tthirdSource:%@\n\tname:%@\n\tuid:%@\n\taccessToken:%@\n\timageUrl:%@\n\texpiresDate:%@\n}", self.thirdSource, self.name, self.uid, self.accessToken, self.imageUrl, self.expiresDate];
}

@end
