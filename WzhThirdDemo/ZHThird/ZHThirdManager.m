//
//  ZHThirdManager.m
//  ZHThirdPlatformDemo
//
//  Created by 吴志和 on 16/1/23.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import "ZHThirdManager.h"
#import <objc/runtime.h>

#import "ZHWeiboManager.h"
#import "ZHQQManager.h"
#import "ZHQQSpaceManager.h"
#import "ZHWeixinManager.h"
#import "ZHWeixinSpaceManager.h"
#import "ZHSMSManager.h"
#import "ZHCopyManager.h"
//#import "NSObject+ZHAddForMethodSwizzing.h"

static ZHThirdManager *instance = nil;

static NSString *kUnSupportShareType = @"不支持的平台";
static NSString *kUnSupportLoginType = @"不支持的第三方登陆方式";

@interface ZHThirdManager ()

@property (nonatomic, assign) ZHThirdType currentThirdType;

@end

@implementation ZHThirdManager

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

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self manager] setupMethodSwizzing];
    });
}

#pragma mark - public method

- (void)registerThirdPlatform:(ZHThirdType)thirdType appKey:(NSString *)appKey secret:(NSString *)secret redirectURI:(NSString *)redirectURI
{
    [[[self thirdClassWithType:thirdType] manager] registerWithAppKey:appKey secret:secret redirectURI:redirectURI];
}

- (void)shareTextToThird:(ZHThirdType)thirdType text:(NSString *)text callBack:(ZHThirdShareCallBack)callBack
{
    id<ZHThirdShareProtocol> manager = [[self thirdClassWithType:thirdType] manager];
    if ([manager respondsToSelector:@selector(shareText:callBack:)]) {
        self.currentThirdType = thirdType;
        [manager shareText:text callBack:callBack];
    }
    else
    {
        callBack(kUnSupportShareType, NO);
        ZHLog(@"%@", kUnSupportShareType);
    }
}

- (void)shareTextToThird:(ZHThirdType)thirdType text:(NSString *)text image:(UIImage *)image callBack:(ZHThirdShareCallBack)callBack
{
    id<ZHThirdShareProtocol> manager = [[self thirdClassWithType:thirdType] manager];
    if ([manager respondsToSelector:@selector(shareText:image:callBack:)]) {
        self.currentThirdType = thirdType;
        [manager shareText:text image:image callBack:callBack];
    }
    else
    {
        callBack(kUnSupportShareType, NO);
        ZHLog(@"%@", kUnSupportShareType);
    }
}

- (void)shareWebPageToThird:(ZHThirdType)thirdType title:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage url:(NSString *)urlStr callBack:(ZHThirdShareCallBack)callBack
{
    id<ZHThirdShareProtocol> manager = [[self thirdClassWithType:thirdType] manager];
    if ([manager respondsToSelector:@selector(shareWebPageWithTitle:description:thumbImage:url:callBack:)]) {
        self.currentThirdType = thirdType;
         [manager shareWebPageWithTitle:title description:description thumbImage:thumbImage url:urlStr callBack:callBack];
    }
    else
    {
        callBack(kUnSupportShareType, NO);
        ZHLog(@"%@", kUnSupportShareType);
    }
}

#pragma mark - third login

- (void)getThirdUserInfo:(ZHThirdType)thirdType callBack:(ZHThirdLoginCallBack)callBack
{
    id<ZHThirdLoginProtocol> manager = [[self thirdClassWithType:thirdType] manager];
    if ([manager respondsToSelector:@selector(loginWithCallBack:)]) {
        self.currentThirdType = thirdType;
        [manager loginWithCallBack:callBack];
    }
    else
    {
        callBack(nil, kUnSupportLoginType, NO);
        ZHLog(@"%@", kUnSupportLoginType);
    }
}

#pragma mark - share private method

- (Class)thirdClassWithType:(ZHThirdType)thirdType
{
    Class thirdClass = nil;
    switch (thirdType) {
        case ZHThirdTypeWeibo:
            thirdClass = ZHWeiboManager.class;
            break;
        case ZHThirdTypeQQ:
            thirdClass = ZHQQManager.class;
            break;
            
        case ZHThirdTypeQQSpace:
            thirdClass = ZHQQSpaceManager.class;
            break;
            
        case ZHThirdTypeWeixin:
            thirdClass = ZHWeixinManager.class;
            break;
            
        case ZHThirdTypeWeixinSpace:
            thirdClass = ZHWeixinSpaceManager.class;
            break;
        case ZHThirdTypeSMS:
            thirdClass = ZHSMSManager.class;
            break;
        case ZHThirdTypeCopy:
            thirdClass = ZHCopyManager.class;
            break;
        default:
            ZHLog(@"Unknow third type = %@", @(thirdType));
            break;
    }
    return thirdClass;
}

- (void)setupMethodSwizzing
{
    SEL applicationOpenURLSel = @selector(application:openURL:sourceApplication:annotation:);
    SEL zh_applicationOpenURLSel = @selector(zh_application:openURL:sourceApplication:annotation:);
    
    SEL applicationHandleOpenURLSel = @selector(application:handleOpenURL:);
    SEL zh_applicationHandleOpenURLSel = @selector(zh_application:handleOpenURL:);
    
    SEL applicationOpenUrlOptionSel = @selector(application:openURL:options:);
    SEL zh_applicationOpenUrlOptionSel = @selector(zh_application:openURL:options:);
    
    [self swizzeSel:applicationOpenURLSel withSel:zh_applicationOpenURLSel];
    
    [self swizzeSel:applicationHandleOpenURLSel withSel:zh_applicationHandleOpenURLSel];
    
    [self swizzeSel:applicationOpenUrlOptionSel withSel:zh_applicationOpenUrlOptionSel];
}

- (void)swizzeSel:(SEL)applicationOpenURLSel withSel:(SEL)zh_applicationOpenURLSel
{
    Class appDelegateClass = [self appDelegateClass];
    
    NSAssert(appDelegateClass, @"[UIApplication sharedApplication].delegate doesn't exist!");
    
    IMP applicationOpenURLImp = class_getMethodImplementation(self.class, applicationOpenURLSel);
    
    IMP zh_applicationOpenURLImp = class_getMethodImplementation(self.class, zh_applicationOpenURLSel);
    
    const char *zh_applicationOpenURLTypes = method_getTypeEncoding(class_getInstanceMethod(self.class, zh_applicationOpenURLSel));
    
    BOOL isAdded = class_addMethod(appDelegateClass, applicationOpenURLSel, applicationOpenURLImp, zh_applicationOpenURLTypes);
    isAdded = class_addMethod(appDelegateClass, zh_applicationOpenURLSel, zh_applicationOpenURLImp, zh_applicationOpenURLTypes);
    
    Method applicationOpenURLMethod = class_getInstanceMethod(appDelegateClass, applicationOpenURLSel);
    Method zh_applicationOpenURLMethod = class_getInstanceMethod(appDelegateClass, zh_applicationOpenURLSel);
    method_exchangeImplementations(applicationOpenURLMethod, zh_applicationOpenURLMethod);
}

/**
 *  获取当前应用的AppDelegate类
 *
 *  @return 当前应用的AppDelegate类
 */
- (Class)appDelegateClass
{
    static Class returnClass = nil;
    
    if (returnClass) {
        return returnClass;
    }
    unsigned int classCount = 0;
    
    NSMutableArray *appDelegates = @[].mutableCopy;
    Class *classLists = objc_copyClassList(&classCount);
    
    for (int i = 0; i < classCount; i++) {
        
        //消除掉CLTilesManagerClient和SCRCException警告
        NSString *className = NSStringFromClass(classLists[i]);
        if ([className isEqualToString:@"CLTilesManagerClient"] ||
            [className isEqualToString:@"SCRCException"]) {
            continue;
        }
        
        //根据isa指针判断一个类是否属于NSObject
        if (object_getClass(object_getClass(classLists[i])) != object_getClass([NSObject class])) {
            continue;
        }
        
        //如果是程序的AppDelegate则首先属于UIResponder且遵守UIApplicationDelegate协议
        if ([classLists[i] isSubclassOfClass:[UIResponder class]] &&
            class_conformsToProtocol(classLists[i], @protocol(UIApplicationDelegate))) {
            [appDelegates addObject:classLists[i]];
        }
    }
    free(classLists);
    
    if (appDelegates.count == 0) {
        returnClass = nil;
    }
    else if (appDelegates.count > 1)
    {
        ZHLog(@"appDelegates count is bigger than 1");
        returnClass = nil;
    }
    else
    {
        returnClass = [appDelegates firstObject];
    }
    return returnClass;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    return NO;
}

- (BOOL)zh_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL retValue = [[ZHThirdManager manager] thirdHandelUrl:url];
    
    return retValue || [self zh_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)zh_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL retValue = [[ZHThirdManager manager] thirdHandelUrl:url];
    
    return retValue || [self zh_application:application handleOpenURL:url];
}

- (BOOL)zh_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    BOOL retValue = [[ZHThirdManager manager] thirdHandelUrl:url];
    
    return retValue || [self zh_application:app openURL:url options:options];
}

- (BOOL)thirdHandelUrl:(NSURL *)url
{
    ZHThirdType thirdType = [ZHThirdManager manager].currentThirdType;
    BOOL retValue = NO;
    
    switch (thirdType) {
        case ZHThirdTypeWeibo:
            if ([url.absoluteString hasPrefix:@"wb"]) {
                retValue = [WeiboSDK handleOpenURL:url delegate:[ZHWeiboManager manager]];
            }
            break;
            
        case ZHThirdTypeQQ:
            if ([url.absoluteString hasPrefix:@"QQ"]) {
                retValue = [QQApiInterface handleOpenURL:url delegate:[ZHQQManager manager]];
            }
            else if ([url.absoluteString hasPrefix:@"tencent"])
            {
                retValue = [TencentOAuth HandleOpenURL:url];
            }
            break;
            
        case ZHThirdTypeQQSpace:
            if ([url.absoluteString hasPrefix:@"QQ"]) {
                retValue = [QQApiInterface handleOpenURL:url delegate:[ZHQQSpaceManager manager]];
            }
            break;
            
        case ZHThirdTypeWeixin:
            if ([url.absoluteString hasPrefix:@"wx"]) {
                retValue = [WXApi handleOpenURL:url delegate:[ZHWeixinManager manager]];
            }
            break;
            
        case ZHThirdTypeWeixinSpace:
            if ([url.absoluteString hasPrefix:@"wx"]) {
                retValue = [WXApi handleOpenURL:url delegate:[ZHWeixinSpaceManager manager]];
            }
            break;
        case ZHThirdTypeSMS:
            break;
        case ZHThirdTypeCopy:
            break;
            
        default:
            break;
    }
    return retValue;
}

@end
