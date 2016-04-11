//
//  ZHThirdUserInfo.h
//  Tianji
//
//  Created by 吴志和 on 16/1/26.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHThirdUserInfo : NSObject

@property (nonatomic, copy) NSString *thirdSource;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSDate *expiresDate;

@end
