//
//  ZHWeixinManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHWeixinManager.h"

static ZHWeixinManager *instance = nil;

@interface ZHWeixinManager ()

@end

@implementation ZHWeixinManager

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

- (int)scene
{
    return WXSceneSession;
}

@end
