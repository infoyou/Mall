//
//  RootViewController.h
//  Mall
//
//  Created by Adam on 14-12-1.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"
#import "ProductAppDelegate.h"
#import "UIColor+expanded.h"

#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

#import "HttpRequestData.h"
#import "UIViewController+ToastMessage.h"

#import "AppManager.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "UIAlertView+Block.h"
#import "MobClick.h"

@interface RootViewController : UIViewController <UIGestureRecognizerDelegate>
{
    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    EGORefreshTableFooterView *_refreshFooterView;
    
    CGFloat _animatedDistance;
}

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *noNetWorkView;

// activity indicator
@property (nonatomic, strong) UIView *activityIndicatorViewBG;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

//// 异常显示
- (void)showAlert:(NSString*)infoStr;

#pragma mark - image for gesture
- (void)addTapGestureRecognizer:(UIView*)targetView;
- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer;

#pragma mark - show or hide tab bar
- (void)showOrHideTabBar:(BOOL)flag;

#pragma mark - 定时 Alert
- (void)showTimeAlert:(NSString*)title message:(NSString*)message;
- (void)timerFireMethod:(NSTimer*)theTimer;

#pragma mark - set Navi Item Edit
//编辑按钮
- (void)setNaviItemEdit;
//点击编辑按钮
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

- (void)adjustView;

#pragma mark - 背景灰色
- (void)showShadowView;

#pragma mark - key board
- (void)initLisentingKeyboard;
- (void)upAnimate;
- (void)downAnimate;

#pragma mark - activity indicator view
- (void)addActivityIndicatorView;
- (void)showActivityIndicatorView;
- (void)closeActivityIndicatorView;

@end
