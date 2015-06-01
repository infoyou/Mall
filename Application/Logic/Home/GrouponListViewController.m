//
//  GrouponListViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "GrouponListViewController.h"
#import "ProductDetailViewController.h"

@interface GrouponListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *backDataArr;
}

@end

@implementation GrouponListViewController
@synthesize product_id;
@synthesize btnComment;
@synthesize btnCommentBG;
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
    self.title = @"团购";
    
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
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,21)];
    [rightButton setImage:[UIImage imageNamed:@"shopCart.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goShoppingCart)forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)adjustView
{
    self.view.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    int tableH = SCREEN_HEIGHT-64;
    mTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, tableH);
    mTableView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    btnCommentBG.hidden = YES;
    btnCommentBG.frame = CGRectMake(0, tableH, SCREEN_WIDTH, 50);
    
    btnComment.layer.cornerRadius = 4;
    [btnComment.layer setMasksToBounds:YES];
    
    [self.view addSubview:self.noNetWorkView];
    mTableView.alpha = 0;
}

#pragma mark - 显示商品评论
- (void) loadListData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    [dataDict setObject:@"2" forKey:@"product_type"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_getproductlist"
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
                                         
                                         backDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         if ([backDataArr count] > 0) {
                                             
                                             NSLog(@"%d",backDataArr.count);
                                             [self.mTableView reloadData];
                                             
                                             if (self.noNetWorkView.superview) {
                                                 [self.noNetWorkView removeFromSuperview];
                                                 mTableView.alpha = 1;
                                             }
                                             
                                         }
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark tableview每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 116;
}

#pragma mark 返回tableview的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return backDataArr.count;
}

#pragma mark - tableview的cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"GrouponListCell" owner:self options:nil] lastObject];
    
    UIView *bgView = (UIView *)[cell viewWithTag:9];

    UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
    
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *desc = (UILabel *)[cell viewWithTag:12];
    UILabel *memberPrice = (UILabel *)[cell viewWithTag:13];
    UILabel *price = (UILabel *)[cell viewWithTag:14];
    UILabel *userCount = (UILabel *)[cell viewWithTag:15];
    
    name.text = [backDataArr[indexPath.row] valueForKey:@"product_name"];
    memberPrice.text = [NSString stringWithFormat:@"￥%@", [backDataArr[indexPath.row] valueForKey:@"price"]];
    NSString *imageUrl = [backDataArr[indexPath.row] valueForKey:@"thumbnail_url"];
    NSString *priceStr = [backDataArr[indexPath.row] valueForKey:@"basic_price"];
    desc.text = [backDataArr[indexPath.row] valueForKey:@"slogan"];
    
    [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //Nothing.
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //Nothing.
    }];
    
    NSString *moneyStr = @"￥";
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", moneyStr, priceStr]];
    
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:HEX_COLOR(@"0xa2a2a2")
                          range:NSMakeRange(1, priceStr.length)];
    
    // money name
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:11.f]
                          range:NSMakeRange(1, moneyStr.length)];
    
    // price name
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:12.f]
                          range:NSMakeRange(1, priceStr.length)];
    
    price.attributedText = attributedStr;
    
    bgView.layer.cornerRadius = 4;
    bgView.layer.masksToBounds = YES;
    
    cell.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailViewController *productVC = [[ProductDetailViewController alloc] init];
    productVC.productId = [backDataArr[indexPath.row] valueForKey:@"product_id"];;
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"团购" style:0 target:nil action:nil];
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

@end
