//
//  ZHRequestTool.h
//  ZHRequestToolDemo
//
//  Created by 吴志和 on 16/1/4.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZHRequestToolResult)(NSURLSessionDataTask * task, id responseObject, NSError *error);

typedef NS_ENUM(NSUInteger, ZHRequestSeriliser) {
    ZHRequestSeriliserHTTP,
    ZHRequestSeriliserJSON,
};

typedef NS_ENUM(NSUInteger, ZHResponseSeriliser) {
    ZHResponseSeriliserHTTP,
    ZHResponseSeriliserJSON,
};

typedef NS_ENUM(NSUInteger, ZHHTTPMethod) {
    ZHHTTPMethodGET,
    ZHHTTPMethodPOST,
};

@interface ZHRequestTool : NSObject

#pragma mark - GET

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(NSDictionary *)parameters requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)GET:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *downloadProgress))progress requestResult:(ZHRequestToolResult)result;

#pragma mark - POST

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)POST:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *uploadProgress))progress requestResult:(ZHRequestToolResult)result;

+ (NSURLSessionDataTask *)HTTPRequestWithMethod:(ZHHTTPMethod)method url:(NSString *)urlStr parameters:(id)parameters requestSerializer:(ZHRequestSeriliser)requestSerializer responseSerializer:(ZHResponseSeriliser)responseSerializer progress:(void (^)(NSProgress *downloadProgress))progress requestResult:(ZHRequestToolResult)result;


@end
