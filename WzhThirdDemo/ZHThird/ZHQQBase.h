//
//  ZHQQBase.h
//  Tianji
//
//  Created by 吴志和 on 16/1/25.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHThirdProtocol.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface ZHQQBase : NSObject<TencentSessionDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) TencentOAuth *oauth;

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) ZHThirdShareCallBack shareCallBack;

@property (nonatomic, copy) ZHThirdLoginCallBack loginCallBack;

- (void)registerWithAppKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI;

- (void)shareWithContentObject:(QQApiObject *)object;

@end
