//
//  ZHThirdShareViewController.m
//  Tianji
//
//  Created by 吴志和 on 16/1/27.
//  Copyright © 2016年 天机. All rights reserved.
//

#import "ZHThirdShareViewController.h"
#import "ZHThirdShareWindow.h"
#import "masonry.h"

#import "WeiboSDK.h"

#import "WXApi.h"

#import <TencentOpenAPI/QQApiInterface.h>

static CGFloat marginY = 20.0;

@interface ZHThirdShareViewController ()

@property (nonatomic, assign) ZHThirdShareType thirdSharedType;

@property (nonatomic, copy) ThirdShareWindowCallBack callBack;

@property (nonatomic, strong) UIView *shareBgView;

@property (nonatomic, strong) UILabel *shareTitleLabel;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *nameLabels;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIControl *cancelControl;
@property (nonatomic, strong) UILabel *cancelLabel;

@end

@implementation ZHThirdShareViewController

#pragma mark - life circle
- (instancetype)initWithSharedType:(ZHThirdShareType)thirdSharedType callBack:(ThirdShareWindowCallBack)callBack
{
    self = [super init];
    if (self) {
        _thirdSharedType = thirdSharedType;
        _callBack = [callBack copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self makeConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupShareBgViewConstraintsShow:YES animated:YES completion:nil];
    });
}
- (void)dealloc
{
}

#pragma mark - view setup

- (void)setupViews
{
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelControlClicked)]];
    self.buttons = @[].mutableCopy;
    self.nameLabels = @[].mutableCopy;
    [self.view addSubview:self.shareBgView];
}

- (void)makeConstraints
{
    CGFloat buttonW = 60.0;
    NSInteger maxButtonsInLine = 4;
    CGFloat marginX = (IPHONE_WIDTH - buttonW * maxButtonsInLine) / (maxButtonsInLine + 1);

    [self setupShareBgViewConstraintsShow:NO animated:NO completion:nil];
    
    [self.shareTitleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.shareBgView).offset(marginY);
        make.centerX.equalTo(self.shareBgView);
    }];
    
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        UILabel *nameLabel = self.nameLabels[i];
        [button mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.height.equalTo(@(buttonW));
            
            if (i < maxButtonsInLine) {
                make.top.equalTo(self.shareTitleLabel.mas_bottom).offset(marginY);
            }
            else
            {
                make.top.equalTo(((UIView *)self.nameLabels[0]).mas_bottom).offset(marginY);
            }
            make.left.equalTo(self.shareBgView).offset(marginX + (marginX + buttonW) * (i % maxButtonsInLine));
        }];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(button);
            make.top.equalTo(button.mas_bottom).offset(6);
        }];
    }
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.shareBgView).offset(10.0);
        make.right.equalTo(self.shareBgView).offset(-10.0);
        make.top.equalTo(((UIView *)[self.nameLabels lastObject]).mas_bottom).offset(marginY);
        make.height.equalTo(@(0.5));
    }];
    
    [self.cancelLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.lineView.mas_bottom).offset(marginY);
        make.centerX.equalTo(self.shareBgView);
    }];
    
    [self.cancelControl mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(self.shareBgView);
        make.top.equalTo(self.lineView.mas_bottom);
        make.bottom.equalTo(self.cancelLabel).offset(marginY);
    }];
}

- (void)setupShareBgViewConstraintsShow:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    CGFloat animationDuration = 0.25;
    if (show) {
        [self.shareBgView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.cancelControl);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    else
    {
        [self.shareBgView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom);
        }];
    }
    
    if (animated) {
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
    else
    {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - event and notification

- (void)shareBgViewClicked
{
}

- (void)cancelControlClicked
{
    [self setupShareBgViewConstraintsShow:NO animated:YES completion:^(BOOL finished) {
        [ZHThirdShareWindow hide];
        if (self.callBack) {
            self.callBack(ZHThirdTypeNone);
            self.callBack = nil;
        }
    }];
}

- (void)thirdButtonClicked:(UIButton *)button
{
    [self setupShareBgViewConstraintsShow:NO animated:YES completion:^(BOOL finished) {
        [ZHThirdShareWindow hide];
        if (self.callBack) {
            self.callBack(button.tag);
            self.callBack = nil;
        }
    }];
}

#pragma mark - getter and setter

- (UIView *)shareBgView
{
    if (!_shareBgView) {
        _shareBgView = [[UIView alloc] init];
        _shareBgView.backgroundColor = [UIColor whiteColor];
        [_shareBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareBgViewClicked)]];
        [_shareBgView addSubview:self.shareTitleLabel];
        
        if ([WXApi isWXAppInstalled]) {
            [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeWeixin];
            [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeWeixinSpace];
        }
        
        if ([QQApiInterface isQQSupportApi]) {
            [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeQQ];
            if (self.thirdSharedType != ZHThirdShareTypeImage && self.thirdSharedType != ZHThirdShareTypeText) {
                [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeQQSpace];
            }
        }
        if ([WeiboSDK isWeiboAppInstalled]) {
            [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeWeibo];
        }
        
        if (self.thirdSharedType == ZHThirdShareTypeText) {
            [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeSMS];
        }
        
        [self shareBgViewAddButtonAndNameWithType:ZHThirdTypeCopy];
        [_shareBgView addSubview:self.lineView];
        [_shareBgView addSubview:self.cancelControl];
    }
    return _shareBgView;
}

- (UILabel *)shareTitleLabel
{
    if (!_shareTitleLabel) {
        _shareTitleLabel = [[UILabel alloc] init];
        _shareTitleLabel.text = @"分享到";
        _shareTitleLabel.font = [UIFont systemFontOfSize:16];
        _shareTitleLabel.textAlignment = NSTextAlignmentCenter;
        _shareTitleLabel.textColor = [UIColor blackColor];
    }
    return _shareTitleLabel;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:0xc7/255.0 green:0xd0/255.0 blue:0xd3/255.0 alpha:1.0];
    }
    return _lineView;
}

- (UIControl *)cancelControl
{
    if (!_cancelControl) {
        _cancelControl = [[UIControl alloc] init];

        [_cancelControl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelControlClicked)]];
        [_cancelControl addTarget:self action:@selector(cancelControlClicked) forControlEvents:UIControlEventTouchUpInside];
        [_cancelControl addSubview:self.cancelLabel];
    }
    return _cancelControl;
}

- (UILabel *)cancelLabel
{
    if (!_cancelLabel) {
        _cancelLabel = [[UILabel alloc] init];
        _cancelLabel.text = @"取消";
        _cancelLabel.font = [UIFont systemFontOfSize:16];
        _cancelLabel.textColor = [UIColor blackColor];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _cancelLabel;
}

#pragma mark - private method

- (void)shareBgViewAddButtonAndNameWithType:(ZHThirdType)thirdType
{
    NSString *iconName = nil;
    NSString *thirdName = nil;
    switch (thirdType) {
        case ZHThirdTypeWeixin:
            iconName = @"wechat";
            thirdName = @"微信";
            break;
        case ZHThirdTypeWeixinSpace:
            iconName = @"wechat_moment";
            thirdName = @"朋友圈";
            break;
        case ZHThirdTypeQQ:
            iconName = @"qq";
            thirdName = @"QQ";
            break;
        case ZHThirdTypeQQSpace:
            iconName = @"qzone";
            thirdName = @"空间";
            break;
        case ZHThirdTypeWeibo:
            iconName = @"sina_weibo";
            thirdName = @"微博";
            break;
        case ZHThirdTypeSMS:
            iconName = @"sms";
            thirdName = @"短信";
            break;
        case ZHThirdTypeCopy:
            iconName = @"copy_link";
            if (self.thirdSharedType == ZHThirdShareTypeImage) {
                thirdName = @"复制图片";
            }
            else if (self.thirdSharedType == ZHThirdShareTypeWebPage){
                thirdName = @"复制链接";
            }
            else
            {
                thirdName = @"复制内容";
            }
            break;
            
        default:
            break;
    }
    NSAssert(iconName && thirdName, @"invalid param iconName = %@ thirdName = %@", iconName, thirdName);
    
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
    if (iconPath) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = thirdType;
        [button setImage:[UIImage imageWithContentsOfFile:iconPath] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(thirdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareBgView addSubview:button];
        [self.buttons addObject:button];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = thirdName;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        [self.shareBgView addSubview:label];
        [self.nameLabels addObject:label];
    }
}

@end
