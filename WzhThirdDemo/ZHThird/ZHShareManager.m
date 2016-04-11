//
//  ZHShareManager.m
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHShareManager.h"
#import "ZHThirdManager.h"

@implementation ZHShareManager

+ (void)shareWithSharedType:(ZHThirdShareType)shareType title:(NSString *)title image:(UIImage *)image url:(NSString *)url description:(NSString *)description weiboDescription:(NSString *)weiboDescription callBack:(ZHThirdShareCallBack)callBack
{
    [ZHThirdShareWindow showWithType:shareType callBack:^(ZHThirdType thirdType) {
        if (thirdType == ZHThirdTypeNone) {
            return;
        }
        
        NSString *text = nil;
        
        if (thirdType == ZHThirdTypeWeibo) {
            text = weiboDescription ? : title;
        }
        else
        {
            text = description ? : title;
        }
        
        switch (shareType) {
            case ZHThirdShareTypeText:
                [[ZHThirdManager manager] shareTextToThird:thirdType text:text callBack:callBack];
                break;
            case ZHThirdShareTypeImage:
                [[ZHThirdManager manager] shareTextToThird:thirdType text:text image:image callBack:callBack];
                break;
            case ZHThirdShareTypeWebPage:
                [[ZHThirdManager manager] shareWebPageToThird:thirdType title:title description:text thumbImage:image url:url callBack:callBack];
                break;
                
            default:
                break;
        }
    }];
}

@end