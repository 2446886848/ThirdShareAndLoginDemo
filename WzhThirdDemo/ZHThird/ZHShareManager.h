//
//  ZHShareManager.h
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHThirdShareWindow.h"

@interface ZHShareManager : NSObject

+ (void)shareWithSharedType:(ZHThirdShareType)shareType title:(NSString *)title image:(UIImage *)image url:(NSString *)url description:(NSString *)description weiboDescription:(NSString *)description callBack:(ZHThirdShareCallBack)callBack;

@end
