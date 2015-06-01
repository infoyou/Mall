//
//  OrderListViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "OrderListViewController.h"

@interface OrderListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *backDataArr;
}

@property (nonatomic, copy) NSString *orderStatus;

@end

@implementation OrderListViewController

@synthesize orderStatus;

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
//    self.title = @"浏览记录";
   
    backDataArr = [NSMutableArray array];
    
    [self loadListData];
    
    [self setNaviItemEdit];
}

- (void)setNaviItemEdit
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(doClear)];
}

- (void)adjustView
{
    int tableH = SCREEN_HEIGHT-64;
    mTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, tableH);
    
    btnCommentBG.hidden = YES;
    btnCommentBG.frame = CGRectMake(0, tableH, SCREEN_WIDTH, 50);
    
    btnComment.layer.cornerRadius = 4;
    [btnComment.layer setMasksToBounds:YES];
    
    mTableView.alpha = 0;
    
    [self.view addSubview:self.noNetWorkView];
}

#pragma mark - 显示商品评论
- (void) loadListData
{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    [dataDict setObject:@"" forKey:@"order_type"];

    [dataDict setValue:self.orderStatus forKey:@"iosStatus"];
//    [dataDict setObject:[NSString stringWithFormat:@"%@", [self.orderStatus JSONString]] forKey:@"status"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_order_getdeffstatusorders"
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
                                     
                                     NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                     
                                     for(NSString * akey in msgDict) {
                                         [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                         
                                         return;
                                     }
                                     
                                     if (backDic != nil) {
                                         
                                         backDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         
                                         if ([backDataArr count] > 0) {

                                             NSLog(@"%d",backDataArr.count);
                                             [self.mTableView reloadData];
                                             
                                             if (self.noNetWorkView.superview) {
                                                 [self.noNetWorkView removeFromSuperview];
                                                 self.mTableView.alpha = 1;
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
    return 191;
}

#pragma mark 返回tableview的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return backDataArr.count;
}

#pragma mark - tableview的cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderListCell" owner:self options:nil] lastObject];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:12];
    
    UILabel *order = (UILabel *)[cell viewWithTag:10];
    UILabel *detail = (UILabel *)[cell viewWithTag:11];
    UILabel *name = (UILabel *)[cell viewWithTag:13];
    UILabel *specialName = (UILabel *)[cell viewWithTag:14];
    UILabel *unitPrice = (UILabel *)[cell viewWithTag:15];
    UILabel *number = (UILabel *)[cell viewWithTag:16];
    UILabel *total = (UILabel *)[cell viewWithTag:17];
    UIButton *sure = (UIButton *)[cell viewWithTag:18];
    
    order.text = [NSString stringWithFormat:@"订单号: %@", [backDataArr[indexPath.row] valueForKey:@"order_code"] ];
    NSString *totalStr = [backDataArr[indexPath.row] valueForKey:@"total_price"];

    NSMutableArray *orderDetailArray = [[backDataArr[indexPath.row] valueForKey:@"orderDetail"] valueForKey:@"lists"];
    
    if (orderDetailArray && [orderDetailArray count] > 0) {

        NSString *nameStr = [orderDetailArray[0] valueForKey:@"product_name"];
        NSString *imageUrl = [orderDetailArray[0] valueForKey:@"thumbnail_url"];
        NSString *priceStr = [orderDetailArray[0] valueForKey:@"sku_product_price"];
        NSString *specificationValue = [orderDetailArray[0] valueForKey:@"specification_value"];
        NSString *skuProductQty = [orderDetailArray[0] valueForKey:@"sku_product_qty"];
        
        name.text = nameStr;
        unitPrice.text = [NSString stringWithFormat:@"单价: ￥%@", priceStr];
        number.text = [NSString stringWithFormat:@"数量:%@", skuProductQty];
        
        [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
        }];
        
        if (specificationValue && specificationValue.length > 0) {
            specialName.text = specificationValue;
        } else {
            specialName.text = @"规格";
        }
    }

    sure.layer.cornerRadius=4;
    [sure.layer setMasksToBounds:YES];
    
    
    NSString *unitStr = @"总价:";
    NSString *moneyStr = [NSString stringWithFormat:@"￥%@", totalStr];
    
    int nameLen = [unitStr length];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", unitStr, moneyStr]];
    
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:HEX_COLOR(@"0xf86052")
                          range:NSMakeRange(nameLen+1, moneyStr.length)];
    
    // money name
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:17.f]
                          range:NSMakeRange(nameLen+1, moneyStr.length)];
    
    total.attributedText = attributedStr;

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSInteger countOfRowsToInsert = [backDataArr count];
        
        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self deleteOrder:indexPath.row];
        
        // 先移出数据，再动画，否则报错
//        [backCommentsArr removeAllObjects];
//        
//        [mTableView beginUpdates];
//        
//        [mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//        [mTableView endUpdates];
        
//        [tableView reloadData];
    }
    
}

- (void)doClear
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认清空？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            
            [self doClearContent];
        }
    }];
}

- (void)doClearContent
{
    NSMutableArray *idArray = [NSMutableArray array];
    
    for (int i=0; i<backDataArr.count; i++) {
        
        NSString *idStr = [backDataArr[i] valueForKey:@"id"];
        [idArray addObject:idStr];
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:idArray forKey:@"ids"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_deletebrowsehistory"
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
                                     
                                     NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                     
                                     for(NSString * akey in msgDict) {
                                         [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                         
                                         return;
                                     }

                                     [self showTimeAlert:@"提示" message:@"清空完成。"];
                                     
                                     [self loadListData];
                                 }
                             }];
     }];

}

- (void)updateOrderStatus:(NSString *)aOrderStatus
{
    
    self.orderStatus = aOrderStatus;    
}

#pragma mark - 删除购物车
- (void) deleteOrder:(int)index
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[backDataArr[index] valueForKey:@"order_id"] forKey:@"order_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_order_deleteOrder"
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
                                     
                                     // msg
                                     NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                     for(NSString * akey in msgDict) {
                                         [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                         
                                         [self.navigationController popViewControllerAnimated:YES];
                                         return;
                                     }
                                     
                                     if (backDic != nil) {
                                         
                                         [self loadListData];
                                     }
                                 }
                             }];
     }];
}

@end
