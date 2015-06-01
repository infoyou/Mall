//
//  RootViewController.m
//  Mall
//
//  Created by Adam on 14-12-1.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize backView;
@synthesize noNetWorkView;

- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad
{

    self.view.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    [self initNoNetWorkView];
    
    [self initData];
    [self adjustView];
    
    // navi bar
    if (CURRENT_OS_VERSION >= IOS7) {
        [self.navigationController.navigationBar setBarTintColor:HEX_COLOR(NAVI_BAR_BG_COLOR)];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[CommonUtils createImageWithColor:HEX_COLOR(NAVI_BAR_BG_COLOR)] forBarMetrics:UIBarMetricsDefault];
    
//    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    //导航栏的标题颜色UITextAttributeTextColor
    NSDictionary *dict = @{NSFontAttributeName :  [UIFont systemFontOfSize:18],
                           NSForegroundColorAttributeName : [UIColor whiteColor]};
    [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    //设置navigationbar的半透明
    [self.navigationController.navigationBar setTranslucent:NO];
    //设置navigationbar上左右按钮字体颜色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self showOrHideTabBar:YES];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init data
- (void)initData
{
    
}

#pragma mark - adjust view
- (void)adjustView
{
    
}

#pragma mark - handle status bar issue for ios7
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - image for gesture
- (void)addTapGestureRecognizer:(UIView *)targetView
{
    targetView.userInteractionEnabled = YES;
    UITapGestureRecognizer *swipeGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(imageviewTouchEvents:)];
    swipeGR.delegate = self;
    
    [targetView addGestureRecognizer:swipeGR];
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
}

#pragma mark - show or hide tab bar
- (void)showOrHideTabBar:(BOOL)flag
{
    //tabbar消失
    [((ProductAppDelegate *)APP_DELEGATE).tabBarController hidesTabBar:flag animated:NO];
}

#pragma mark - show Alert
- (void)showAlert:(NSString*)infoStr
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:infoStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - 定时 Alert
- (void)showTimeAlert:(NSString*)title message:(NSString*)message
{
    
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:NO];
    [promptAlert show];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
}

- (void)setNaviItemEdit
{
    //编辑按钮
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = @"编辑";
}


//点击编辑按钮
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    // Don't show the Back button while editing.
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
    
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
        NSLog(@"abc");
        
    } else {//点击完成按钮
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        NSLog(@"123");
    }
}

#pragma mark - 无网络时处理
- (void)initNoNetWorkView
{
    UIView *tmpNetWorkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    tmpNetWorkView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    UIImageView *noNetWorkImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nonContent.png"]];
    noNetWorkImgV.frame = CGRectMake((SCREEN_WIDTH - 132)/2, 80, 132, 132);
    [tmpNetWorkView addSubview:noNetWorkImgV];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 270, SCREEN_WIDTH, 30)];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.text = @"啊哦! 暂时没有记录哦!";
    promptLabel.textColor = HEX_COLOR(@"0x333333");
    [tmpNetWorkView addSubview:promptLabel];
    
    UIButton *btnNoNetWork = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNoNetWork setFrame:CGRectMake((SCREEN_WIDTH - 108)/2, 320, 108 , 36)];
    [btnNoNetWork setImage:[UIImage imageNamed:@"noNetWork.png"] forState:UIControlStateNormal];
    [btnNoNetWork addTarget:self action:@selector(btnNoNetWorkClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tmpNetWorkView addSubview:btnNoNetWork];
    
    self.noNetWorkView = tmpNetWorkView;
}

#pragma mark －无网络时点击事件
- (void)btnNoNetWorkClicked:(id)sender
{
    
}

#pragma mark - 背景灰色
- (void)showShadowView
{
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  SCREEN_HEIGHT)];
    self.backView.backgroundColor = [UIColor grayColor];
    self.backView.alpha = 0.5;
    
    [APP_DELEGATE.window addSubview:self.backView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
}

// 监听键盘
- (void)initLisentingKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

#pragma mark - animate
- (void)upAnimate
{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)downAnimate
{
    if (_animatedDistance == 0) {
        return;
    }
    
    //    CGRect viewFrame = self.view.frame;
    //    viewFrame.origin.y += _animatedDistance;
    
    CGRect viewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    _animatedDistance = 0;
}

#pragma mark - keyboard show or hidden
-(void)autoMovekeyBoard:(float)h withDuration:(float)duration
{
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGRect rect = self.view.frame;
        if (h) {
            if (SCREEN_HEIGHT > 480) {
                self.view.frame = CGRectMake(0.0f, -40, self.view.frame.size.width, self.view.frame.size.height);
            } else {
                self.view.frame = CGRectMake(0.0f, -110, self.view.frame.size.width, self.view.frame.size.height);
            }
            
        } else {
            rect.origin.y = ([CommonUtils is7System] ? 0 : 0);
            self.view.frame = rect;
        }
        
    } completion:^(BOOL finished) {
        // stub
    }];
    
}

#pragma mark - Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:0 withDuration:animationDuration];

}

#pragma mark - activity indicator view
- (void)addActivityIndicatorView
{
    
    // bg
    self.activityIndicatorViewBG = [[UIView alloc] initWithFrame:CGRectMake(126, 282, 67, 67)];
    self.activityIndicatorViewBG.backgroundColor = [UIColor grayColor];
    self.activityIndicatorViewBG.alpha = 0.7f;
    
    // activity indicator view
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.frame = CGRectMake(15, 15, 37, 37);
    [self.activityIndicatorViewBG addSubview:self.activityIndicatorView];
    
    self.activityIndicatorViewBG.layer.cornerRadius = 6;
    self.activityIndicatorViewBG.layer.masksToBounds = YES;
    
    [self.view addSubview:self.activityIndicatorViewBG];
}

- (void)showActivityIndicatorView
{
    
    self.activityIndicatorViewBG.hidden = NO;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)closeActivityIndicatorView
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.activityIndicatorViewBG.hidden = YES;
}

@end
