//
//  ZHWeixinSpaceManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHWeixinSpaceManager.h"

static ZHWeixinSpaceManager *instance = nil;

@interface ZHWeixinSpaceManager ()

@end

@implementation ZHWeixinSpaceManager

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
    return WXSceneTimeline;
}

@end
