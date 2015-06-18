//
//  ProfileViewController.m
//  Mall
//
//  Created by Adam on 14-12-13.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProductDetailViewController.h"
#import "SettingViewController.h"
#import "FavoriteViewController.h"
#import "BrowseViewController.h"
#import "LoginViewController.h"
#import "AddressListViewController.h"
#import "OrderListViewController.h"
#import "ShoppingCartViewController.h"
#import "ExperienceViewController.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ProfileViewController

@synthesize mTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showOrHideTabBar:NO];
    
    [self initTabHeadView];
}

- (void)initNaviBarView
{
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [rightButton setImage:[UIImage imageNamed:@"icon38.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(doSetting) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    self.title = @"个人中心";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNaviBarView];
}

- (void)adjustView
{
    
    if (SCREEN_HEIGHT < 568) {
        
        mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y, mTableView.frame.size.width, mTableView.frame.size.height - (64+35));
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTabHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 195)];

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headView.frame];
    bgView.image = [UIImage imageNamed:@"icon50.png"];
    [headView addSubview:bgView];
    
    UITableViewCell *tabHeadView = nil;
    
    if ( ![@"" isEqualToString:[AppManager instance].userId] ) {

        // 已经登录
        tabHeadView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileHeadView" owner:self options:nil] lastObject];
        
        tabHeadView.contentView.backgroundColor = [UIColor clearColor];
        
        UIImageView *avator = (UIImageView *)[tabHeadView viewWithTag:10];
        [avator sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[AppManager instance].userImageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
            avator.image = image;
        }];
        
        avator.layer.borderWidth = 2;
        avator.layer.borderColor = HEX_COLOR(@"0xffffff").CGColor;
        avator.layer.cornerRadius = avator.bounds.size.width/2;
        avator.layer.masksToBounds = YES;
        
        UILabel *name = (UILabel *)[tabHeadView viewWithTag:11];
        if(![[AppManager instance].userNickName isEqualToString:@""]) {
            name.text = [AppManager instance].userNickName;
        } else {
            name.text = [AppManager instance].userName;
        }
        
        UILabel *point = (UILabel *)[tabHeadView viewWithTag:12];
        NSString *pointPrefixStr = @"您现在拥有积分 ";
        int nameLen = [pointPrefixStr length];

        NSString *pointStr = [AppManager instance].userPoint;
        int sloganLen = [pointStr length];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", pointPrefixStr, pointStr]];
        
        [attributedStr addAttribute:NSFontAttributeName
                              value:[UIFont boldSystemFontOfSize:16.f]
                              range:NSMakeRange(nameLen, sloganLen)];
        [attributedStr addAttribute:NSForegroundColorAttributeName
                              value:HEX_COLOR(@"0xfcff00")
                              range:NSMakeRange(nameLen, sloganLen)];
        
        point.attributedText = attributedStr;

    } else {
        
        // 未登录
        tabHeadView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileVisitorHeadView" owner:self options:nil] lastObject];
        
        tabHeadView.contentView.backgroundColor = [UIColor clearColor];
        
        UIButton *btnLogin = (UIButton *)[tabHeadView viewWithTag:10];
        btnLogin.layer.cornerRadius = 2;
        btnLogin.layer.masksToBounds = YES;
        [btnLogin addTarget:self action:@selector(doLoginOrRegist) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *addressView = (UIView *)[tabHeadView viewWithTag:110];
    UIView *favoriteView = (UIView *)[tabHeadView viewWithTag:111];
    
    [self addTapGestureRecognizer:addressView];
    [self addTapGestureRecognizer:favoriteView];
    
    [headView addSubview:tabHeadView.contentView];
    self.mTableView.tableHeaderView = headView;
}

#pragma mark - UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
           
        case 1:
            return 3;
            break;
            
        case 2:
            return 3;
            break;
            
        default:
            break;
    }
    
    return 0;
}

/// 绑定cell的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"HomeMallCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell != nil) {

        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    if (nil == cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil] lastObject];
    }
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:10];
    icon.image = [UIImage imageNamed:[[[self getCellImgDictionary] objectForKey:[NSNumber numberWithInt:(indexPath.section + 1) * 100]] objectAtIndex:indexPath.row]];
    
    UILabel *textVal = (UILabel *)[cell viewWithTag:11];
    textVal.text = [[[self getCellTextDictionary] objectForKey:[NSNumber numberWithInt:(indexPath.section + 1) * 100]] objectAtIndex:indexPath.row];
    
    CGRect profileTxtRect = [CommonUtils sizeWithText:textVal.text withFont:textVal.font size:CGSizeMake(200, 21)];
    
    UIButton *badge = (UIButton *)[cell viewWithTag:12];
    badge.hidden = YES;
    
    if ([AppManager instance].profileCellNumberDict != nil) {
        
        NSString *badgeNum = [[[self getCellNumberDictionary] objectForKey:[NSNumber numberWithInt:(indexPath.section + 1) * 100]] objectAtIndex:indexPath.row];
        
        if (![badgeNum isEqualToString:@""]) {
            int badgeVal = [badgeNum intValue];
            
            if (badgeVal > 0) {

                badge.frame = CGRectOffset(badge.frame, profileTxtRect.size.width+5, 0);
                [badge setTitle:badgeNum forState:UIControlStateNormal];
                badge.hidden = NO;
            }
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSMutableDictionary *)getCellImgDictionary
{
    NSMutableArray *cell0TextArray = [[NSMutableArray alloc] initWithObjects:@"icon49.png", @"icon48.png", @"icon47.png", @"icon46.png", nil];
    
    NSMutableArray *cell1TextArray = [[NSMutableArray alloc] initWithObjects:@"experience.png", @"shoppingCart.png", @"icon44.png", nil];
    
    NSMutableArray *cell2TextArray = [[NSMutableArray alloc] initWithObjects:@"icon43.png", @"icon42.png", @"logistics.png", nil];
    
    NSMutableDictionary *imgDic = [NSMutableDictionary dictionary];
    [imgDic setObject:cell0TextArray forKey:[NSNumber numberWithInt:100]];
    [imgDic setObject:cell1TextArray forKey:[NSNumber numberWithInt:200]];
    [imgDic setObject:cell2TextArray forKey:[NSNumber numberWithInt:300]];
    
    return imgDic;
}

- (NSMutableDictionary *)getCellTextDictionary
{
    NSMutableArray *cell0TextArray = [[NSMutableArray alloc] initWithObjects:@"到店体验订单", @"未付款订单", @"待收货订单", @"已完成订单", nil];
    
    NSMutableArray *cell1TextArray = [[NSMutableArray alloc] initWithObjects:@"到店体验车", @"购物车", @"优惠券",nil];
    
    NSMutableArray *cell2TextArray = [[NSMutableArray alloc] initWithObjects:@"我的收藏", @"浏览记录", @"物流查询", nil];
    
    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
    [textDic setObject:cell0TextArray forKey:[NSNumber numberWithInt:100]];
    [textDic setObject:cell1TextArray forKey:[NSNumber numberWithInt:200]];
    [textDic setObject:cell2TextArray forKey:[NSNumber numberWithInt:300]];
    
    return textDic;
}

- (NSMutableDictionary *)getCellNumberDictionary
{
    
//    "browse_count" = 3;
//    "close_order_count" = 0;
//    "coupon_count" = 0;
//    "delivered_order_count" = 0;
//    "favorite_count" = 0;
//    "member_id" = K5KASRHo;
//    "non_payment_order_count" = 0;
//    "raffle_count" = 0;
//    "shoppingcart_count" = 3;
//    "storecart_count" = 3;
//    "to_store_experience_order_count" = 0;
    
    NSMutableArray *cell0TextArray = [[NSMutableArray alloc] initWithObjects:[[AppManager instance].profileCellNumberDict valueForKey:@"to_store_experience_order_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"non_payment_order_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"delivered_order_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"close_order_count"], nil];
    
    NSMutableArray *cell1TextArray = [[NSMutableArray alloc] initWithObjects:[[AppManager instance].profileCellNumberDict valueForKey:@"storecart_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"shoppingcart_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"coupon_count"], nil];
    
    NSMutableArray *cell2TextArray = [[NSMutableArray alloc] initWithObjects:[[AppManager instance].profileCellNumberDict valueForKey:@"favorite_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"browse_count"], [[AppManager instance].profileCellNumberDict valueForKey:@"coupon_count"], nil];
    
    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
    [textDic setObject:cell0TextArray forKey:[NSNumber numberWithInt:100]];
    [textDic setObject:cell1TextArray forKey:[NSNumber numberWithInt:200]];
    [textDic setObject:cell2TextArray forKey:[NSNumber numberWithInt:300]];
    
    return textDic;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (![self isAvailableGo]) {
        return;
    }
    
    int cellRow = [indexPath row];
    switch ([indexPath section]) {
        case 0:
        {
            OrderListViewController *orderVC = [[OrderListViewController alloc] init];

            NSString *orderTitle = @"";
            NSString *orderStatus = @"";
            
            switch (cellRow) {
                case 0:
                {
                    // 到店体验订单
                    orderTitle = @"到店体验订单";
                    orderStatus = @"51, 52, 53, 54";
                }
                    break;
                
                case 1:
                {
                    // 未付款订单
                    orderTitle = @"未付款订单";
                    orderStatus = @"10, 20";
                }
                    break;
                    
                case 2:
                {
                    // 待收货订单
                    orderTitle = @"待收货订单";
                    orderStatus = @"11, 12";
                }
                    break;
                    
                case 3:
                {
                    // 已完成订单
                    orderTitle = @"已完成订单";
                    orderStatus = @"13, 23, 54";
                }
                    break;
                    
                default:
                    break;
            }
            
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
            orderVC.title = orderTitle;
            
            [orderVC updateOrderStatus:orderStatus];
            
            [self.navigationController pushViewController:orderVC animated:YES];

        }
            break;
            
        case 1:
        {
            switch (cellRow) {
                case 0:
                {
                    // 到店体验车
                    ExperienceViewController *shoppingCartVC = [[ExperienceViewController alloc] init];
                    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
                    
                    [self.navigationController pushViewController:shoppingCartVC animated:YES];

                }
                    break;
                    
                case 1:
                {
                    // 购物车
                    ShoppingCartViewController *shoppingCartVC = [[ShoppingCartViewController alloc] init];
                    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
                    
                    [self.navigationController pushViewController:shoppingCartVC animated:YES];
                }
                    break;
                    
                case 2:
                {
                    // 优惠券
                    [self showHUDWithText:@"敬请期待..."];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            switch (cellRow) {
                case 0:
                {
                    // 我的收藏
                    
                    FavoriteViewController *favoriteVC = [[FavoriteViewController alloc] init];
                    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
                    
                    [self.navigationController pushViewController:favoriteVC animated:YES];
                }
                    break;
                    
                case 1:
                {
                    // 浏览记录
                    
                    BrowseViewController *browseVC = [[BrowseViewController alloc] init];
                    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
                    
                    [self.navigationController pushViewController:browseVC animated:YES];
                }
                    break;
                    
                case 2:
                {
                    // 物流查询
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
//    ProductDetailViewController *productVC = [[ProductDetailViewController alloc] init];
//    productVC.product_id = @"eZGATxA";
//    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
//
//    [self.navigationController pushViewController:productVC animated:YES];
    
//    ProductAppDelegate *delegate = (ProductAppDelegate *)APP_DELEGATE;
//    [delegate.tabBarController.navigationController pushViewController:productVC animated:YES];
}

- (void)doSetting
{

    if ( ![@"" isEqualToString:[AppManager instance].userId] ) {
        
        // 已经登录
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
        [self.navigationController pushViewController:settingVC animated:YES];
    } else {
        
        [self showHUDWithText:@"请登录后，再操作。"];
    }
}

- (void)doLoginOrRegist
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
    [self.navigationController pushViewController:loginVC animated:YES];
    
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    switch (viewTag) {
        case 110:
        {
            if (![self isAvailableGo]) {
                return;
            }
            
            DLog(@"Address List");
            AddressListViewController *addressVC = [[AddressListViewController alloc] init];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
            
            [self.navigationController pushViewController:addressVC animated:YES];
        }
            break;
        
        case 111:
        {
            if (![self isAvailableGo]) {
                return;
            }
            
            DLog(@"Favorite List");
            FavoriteViewController *favoriteVC = [[FavoriteViewController alloc] init];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:0 target:nil action:nil];
            
            [self.navigationController pushViewController:favoriteVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)isAvailableGo
{
    if (![@"" isEqualToString:[AppManager instance].userId]) {
        
        return YES;
    } else {
        [self showHUDWithText:@"请登录后在操作!"];
        return NO;
    }
}

@end
