//
//  StoreListViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "StoreListViewController.h"
#import "MapViewController.h"
#import "StoreDetailViewController.h"

@interface StoreListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    NSMutableArray *backDataArr;
}

@end

@implementation StoreListViewController
@synthesize product_id;
@synthesize mSearchBar;
@synthesize mSearchCancelBtn;
@synthesize mTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"门店列表";
    
    [self adjustView];
    
    [self loadListData];
    
    //    [self setNaviItemEdit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNaviItemEdit
{
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,21)];
    [rightButton setImage:[UIImage imageNamed:@"shopCart.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goShoppingCart)forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
}

- (void)adjustView
{
    self.view.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    int searchH = 44;
    int tableH = SCREEN_HEIGHT-64-searchH;
    
    mTableView.frame = CGRectMake(0, searchH, SCREEN_WIDTH, tableH);
    mTableView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    mSearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, searchH);
    [mSearchBar setBarTintColor:HEX_COLOR(@"0xdadada")];
    [mSearchBar setBackgroundColor:HEX_COLOR(NAVI_BAR_BG_COLOR)];
    [mSearchBar setTintColor:HEX_COLOR(@"0x333333")];
    [mSearchBar.layer setBorderWidth:1.0f];
    [mSearchBar.layer setBorderColor:HEX_COLOR(@"0xdadada").CGColor];
    [mSearchBar.layer setMasksToBounds:YES];
    mSearchBar.delegate = self;
    
    mSearchCancelBtn.backgroundColor = HEX_COLOR(@"0xdcd6d6");
    mSearchCancelBtn.hidden = YES;
    
    [self.view addSubview:self.noNetWorkView];
    mTableView.alpha = 0;
}

#pragma mark - 显示商品评论
- (void) loadListDataByParam
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:mSearchBar.text forKey:@"search"];
//    [dataDict setObject:@"31.25009800" forKey:@"latitude"];
//    [dataDict setObject:@"121.55013600" forKey:@"longitude"];
//    [dataDict setObject:@"31" forKey:@"province_id"];
//    [dataDict setObject:@"12" forKey:@"city_id"];
//    [dataDict setObject:@"64" forKey:@"area_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_location_getareastores"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString*requestStr) {
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         // [self.navigationController popViewControllerAnimated:YES];
                                         
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backDic != nil) {
                                         
                                         if (backDataArr && backDataArr.count > 0) {
                                             backDataArr = nil;
                                         }
                                         
                                         backDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         if ([backDataArr count] > 0) {
                                             
                                             NSLog(@"%d",backDataArr.count);
                                             [self.mTableView reloadData];
                                             
                                             if (self.noNetWorkView.superview) {
                                                 [self.noNetWorkView removeFromSuperview];
                                                 mTableView.alpha = 1;
                                             }
                                         } else {
                                             
                                             [self.view addSubview:self.noNetWorkView];
                                         }
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark - 显示商品评论
- (void) loadListData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_corporation_getstorelist"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString*requestStr) {
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         // [self.navigationController popViewControllerAnimated:YES];
                                         
                                         [self.view addSubview:self.noNetWorkView];
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backDic != nil) {
                                         
                                         backDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         
                                         if ([backDataArr count] > 0) {
                                             
                                             NSLog(@"%d",backDataArr.count);
                                             [self.mTableView reloadData];
                                             
                                             if (self.noNetWorkView.superview) {
                                                 [self.noNetWorkView removeFromSuperview];
                                                 mTableView.alpha = 1;
                                             }
                                         } else {
                                             
                                             [self.view addSubview:self.noNetWorkView];
                                         }
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark tableview每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

#pragma mark 返回tableview的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return backDataArr.count;
}

#pragma mark - tableview的cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"StoreListCell" owner:self options:nil] lastObject];
    
    UIView *bgView = (UIView *)[cell viewWithTag:9];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
    
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *desc = (UILabel *)[cell viewWithTag:12];
    
    name.text = [backDataArr[indexPath.row] valueForKey:@"store_name_cn"];
    desc.text = [backDataArr[indexPath.row] valueForKey:@"store_address"];
    
    /*
    NSString *imageUrl = [backDataArr[indexPath.row] valueForKey:@"qrcode_url"];
    [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //Nothing.
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //Nothing.
    }];
    */
    
    bgView.layer.cornerRadius = 4;
    bgView.layer.masksToBounds = YES;
    
    UIView *callView = (UIView *)[cell viewWithTag:13];
    UIView *mapView = (UIView *)[cell viewWithTag:14];
    UIView *activityView = (UIView *)[cell viewWithTag:15];
    
    [self addTapGestureRecognizer:callView];
    [self addTapGestureRecognizer:mapView];
    [self addTapGestureRecognizer:activityView];
    
    cell.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreDetailViewController *productVC = [[StoreDetailViewController alloc] init];
    productVC.storeId = [backDataArr[indexPath.row] valueForKey:@"store_id"];;
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"门店列表" style:0 target:nil action:nil];
    [self.navigationController pushViewController:productVC animated:YES];
    
}

- (void)goShoppingCart
{
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认清空？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //
    //    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
    //
    //        if (buttonIndex == 1) {
    //
    //        }
    //    }];
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    switch (viewTag) {
        case 13:
        {
            
        }
            break;
            
        case 14:
        {

            NSInteger cellRow = [self.mTableView indexPathForCell:(UITableViewCell*)[[view superview] superview]].row;
            
            NSString *latitudeStr = [backDataArr[cellRow] valueForKey:@"latitude"];
            NSString *longitudeStr = [backDataArr[cellRow] valueForKey:@"longitude"];
            NSString *titleStr = [backDataArr[cellRow] valueForKey:@"store_name_cn"];
            NSString *storeAddressStr = [backDataArr[cellRow] valueForKey:@"store_address"];
            
            // Map
            MapViewController *mapVC = [[MapViewController alloc] initWithLatitude:[latitudeStr doubleValue]
                                                                       longitude:[longitudeStr doubleValue]
                                                                           title:titleStr
                                                                          subTitle:storeAddressStr];
            
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"门店列表" style:0 target:nil action:nil];
            [self.navigationController pushViewController:mapVC animated:YES];
            
        }
            break;
            
        case 15:
        {
            [self showTimeAlert:@"" message:@"门店活动"];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate method

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    mSearchCancelBtn.hidden = NO;
    mSearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-mSearchCancelBtn.frame.size.width, mSearchBar.frame.size.height);
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self loadListDataByParam];
    [searchBar resignFirstResponder];
}

- (IBAction)doSearchBarCancelButtonClicked
{
    if ([mSearchBar isFirstResponder] || ![@"" isEqualToString:mSearchBar.text]) {

        mSearchCancelBtn.hidden = YES;
        mSearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, mSearchBar.frame.size.height);
        
        mSearchBar.text = @"";
        [mSearchBar resignFirstResponder];
        [self loadListData];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
