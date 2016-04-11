//
//  ZHRequestTool.m
//  ZHRequestToolDemo
//
//  Created by 吴志和 on 16/1/4.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import "ZHRequestTool.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@implementation ZHRequestTool

#pragma mark - GET

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr requestResult:(ZHRequestToolResult)result;
{
    return [self GET:urlStr parameters:nil requestSerializer:ZHRequestSeriliserHTTP responseSerializer:ZHResponseSeriliserHTTP progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(NSDictionary *)parameters requestResult:(ZHRequestToolResult)result
{
    return [self GET:urlStr parameters:parameters requestSerializer:ZHRequestSeriliserHTTP responseSerializer:ZHResponseSeriliserHTTP progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self GET:urlStr parameters:nil requestSerializer:ZHRequestSeriliserHTTP responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self GET:urlStr parameters:nil requestSerializer:requestSerializer responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self GET:urlStr parameters:parameters requestSerializer:ZHRequestSeriliserHTTP responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self GET:urlStr parameters:parameters requestSerializer:requestSerializer responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *downloadProgress))progress requestResult:(ZHRequestToolResult)result
{
    return [self HTTPRequestWithMethod:ZHHTTPMethodGET url:urlStr parameters:parameters requestSerializer:requestSerializer responseSerializer:responseSerializer progress:progress requestResult:result];
}

#pragma mark - POST

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestResult:(ZHRequestToolResult)result
{
    return [self POST:urlStr parameters:parameters requestSerializer:ZHRequestSeriliserHTTP responseSerializer:ZHResponseSeriliserHTTP progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self POST:urlStr parameters:parameters requestSerializer:ZHRequestSeriliserHTTP responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result
{
    return [self POST:urlStr parameters:parameters requestSerializer:requestSerializer responseSerializer:responseSerializer progress:nil requestResult:result];
}

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *uploadProgress))progress requestResult:(ZHRequestToolResult)result
{
    return [self HTTPRequestWithMethod:ZHHTTPMethodPOST url:urlStr parameters:parameters requestSerializer:requestSerializer responseSerializer:responseSerializer progress:progress requestResult:result];
}

#pragma mark - public

+ (NSURLSessionDataTask *)HTTPRequestWithMethod:(ZHHTTPMethod)method url:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *downloadProgress))progress requestResult:(ZHRequestToolResult)result
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if (requestSerializer == ZHRequestSeriliserHTTP) {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    else if (requestSerializer == ZHRequestSeriliserJSON) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if (responseSerializer == ZHResponseSeriliserHTTP) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    else if (responseSerializer == ZHResponseSeriliserJSON)
    {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    //处理参数
    if (![parameters isKindOfClass:[NSDictionary class]]) {
        parameters = [parameters mj_keyValues];
    }

    NSURLSessionDataTask *task = nil;
    switch (method) {
        case ZHHTTPMethodGET:
        {
            task = [manager GET:urlStr parameters:parameters progress:progress success:^(NSURLSessionDataTask * task, id responseObject) {
                result(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                result(task, nil, error);
            }];
        }
        break;
            
        case ZHHTTPMethodPOST:
        {
            task = [manager POST:urlStr parameters:parameters progress:progress success:^(NSURLSessionDataTask * task, id responseObject) {
                result(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                result(task, nil, error);
            }];
        }
        break;
            
        default:
            NSAssert(NO, @"Unknown methhod");
            break;
    }
    return task;
}

@end
