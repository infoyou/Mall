//
//  ShoppingCartViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ShoppingCartViewController.h"

#define PAY_NUMBER_TAG      2001

@interface ShoppingCartViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *backDataArr;
    NSMutableDictionary *selIndexArr;
    
    NSMutableDictionary *cellPriceArr;
    NSMutableDictionary *cellCountArr;
    
    NSMutableDictionary *totalDict;
    int allCellState;
}

@end

@implementation ShoppingCartViewController

@synthesize product_id;
@synthesize btnComment;
@synthesize btnSelBG;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    [self showOrHideTabBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"购物车";
    
    backDataArr = [NSMutableArray array];
    selIndexArr = [NSMutableDictionary dictionary];
    
    cellPriceArr = [NSMutableDictionary dictionary];
    cellCountArr = [NSMutableDictionary dictionary];
    
    totalDict = [NSMutableDictionary dictionary];
    
    [self loadShoppingCartData];
    
    [self setNaviItemEdit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustView
{
    int tableH = SCREEN_HEIGHT - 64 - 50;
    mTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, tableH);
    
    btnCommentBG.frame = CGRectMake(0, tableH, SCREEN_WIDTH, 50);
    
    allCellState = 0;
    UIImageView *selIV = (UIImageView *)[btnSelBG viewWithTag:9];
    selIV.image = [UIImage imageNamed:@"popUnSel.png"];
    [self addTapGestureRecognizer:btnSelBG];
    
    [btnComment setTitle:@"结算" forState:UIControlStateNormal];
    btnComment.layer.cornerRadius = 4;
    [btnComment.layer setMasksToBounds:YES];
    btnComment.alpha = 0.5;
}

#pragma mark - 显示商品评论
- (void) loadShoppingCartData
{
    
    // cart_type:购物车的类别。0:在线购物车，1:到店体验车
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    [dataDict setObject:@"0" forKey:@"cart_type"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_getshoppingcartlist"
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
                                         NSLog(@"%d",backDataArr.count);
                                         
                                         NSUInteger size = backDataArr.count;
                                         
                                         for (NSUInteger i=0; i<size; i++) {
                                             [selIndexArr setObject:@"0" forKey:@(i)];
                                             
                                             [cellCountArr setObject:[backDataArr[i] valueForKey:@"sku_qty"] forKey:@(i)];
                                             
                                             NSString *priceStr = [[backDataArr[i] valueForKey:@"product_detail"] valueForKey:@"price"];
                                             [cellPriceArr setObject:priceStr forKey:@(i)];
                                         }
                                         
                                         [self.mTableView reloadData];
                                         
                                         [btnComment setTitle:@"结算" forState:UIControlStateNormal];
                                         btnComment.alpha = 0.5;
                                         
                                        // [btnComment setTitle:[NSString stringWithFormat:@"结算(%d)", backDataArr.count] forState:UIControlStateNormal];
                                         
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
    
    static NSString *CellIdentifier = @"ShoppingCartCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell != nil) {
        
        for( UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    if (cell == nil) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ShoppingCartCell" owner:self options:nil] lastObject];
    }
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:9];
    UILabel *name = (UILabel *)[cell viewWithTag:10];
    UILabel *size = (UILabel *)[cell viewWithTag:11];
    UILabel *price = (UILabel *)[cell viewWithTag:13];
    
    NSString *nameStr = [[backDataArr[indexPath.row] valueForKey:@"product_detail"] valueForKey:@"product_name"];
    NSString *imageUrl = [[backDataArr[indexPath.row] valueForKey:@"product_detail"] valueForKey:@"thumbnail_url"];
    NSString *priceStr = [[backDataArr[indexPath.row] valueForKey:@"product_detail"] valueForKey:@"price"];
    NSString *sizeStr = [backDataArr[indexPath.row] valueForKey:@"size"];
    
    if (![@"default" isEqualToString:sizeStr]) {
        size.text = sizeStr;
    } else {
        size.text = @"";
    }
    
    [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //Nothing.
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //Nothing.
    }];
    
    name.text = nameStr;
    
    // Number text
    UITextField *addCount = (UITextField *)[cell viewWithTag:PAY_NUMBER_TAG];
    addCount.text = [backDataArr[indexPath.row] valueForKey:@"sku_qty"];
    
    // Bg view
    UIView *btnBgView = (UIView *)[cell viewWithTag:110];
    btnBgView.layer.borderColor = HEX_COLOR(@"0xb7b7b7").CGColor;
    btnBgView.layer.borderWidth = 0.5;
    
    UIView *leftSplitView = (UIView *)[cell viewWithTag:16];
    leftSplitView.frame = CGRectOffset(leftSplitView.frame, -0.5, 0);
    
    UIView *rightSplitView = (UIView *)[cell viewWithTag:17];
    rightSplitView.frame = CGRectOffset(rightSplitView.frame, -0.5, 0);
    
    // Sub
    UIButton *btnSub = (UIButton *)[cell viewWithTag:111];
    [btnSub addTarget:self action:@selector(doSubCount:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add
    UIButton *btnAdd = (UIButton *)[cell viewWithTag:112];
    [btnAdd addTarget:self action:@selector(doAddCount:) forControlEvents:UIControlEventTouchUpInside];
    
    // Price
    NSString *unitStr = @"";
    NSString *moneyStr = @"￥";
    
    int nameLen = [unitStr length];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@%@", unitStr, moneyStr, priceStr]];
    
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:HEX_COLOR(@"0xf86052")
                          range:NSMakeRange(nameLen+1, moneyStr.length + priceStr.length)];
    
    // money name
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:11.f]
                          range:NSMakeRange(nameLen+1, moneyStr.length)];
    
    // price name
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:15.f]
                          range:NSMakeRange(nameLen+1 + moneyStr.length, priceStr.length)];
    
    price.attributedText = attributedStr;
    
    // Sel Icon
    UIImageView *selView = (UIImageView *)[cell viewWithTag:8];
    
    if ([[selIndexArr objectForKey:@(indexPath.row)] isEqualToString:@"1"]) {
        
        selView.image = [UIImage imageNamed:@"popSeled.png"];
    } else {
        selView.image = [UIImage imageNamed:@"popUnSel.png"];
    }
    
    if (![totalDict objectForKey:@(indexPath.row)]) {

        [totalDict setObject:@([addCount.text intValue] * [priceStr doubleValue]) forKey:@(indexPath.row)];
    } else {
        
        [totalDict removeObjectForKey:@(indexPath.row)];
        [totalDict setObject:@([addCount.text intValue] * [priceStr doubleValue]) forKey:@(indexPath.row)];
    }
    
//    if (indexPath.row == [backDataArr count]-1) {
//        
//        [self showTotalPrice];
//    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *selView = (UIImageView *)[selCell viewWithTag:8];
    
    if (![[selIndexArr objectForKey:@(indexPath.row)] isEqualToString:@"1"]) {
        
        [selIndexArr setObject:@"1" forKey:@(indexPath.row)];
        selView.image = [UIImage imageNamed:@"popSeled.png"];
    } else {
        
        [selIndexArr setObject:@"0" forKey:@(indexPath.row)];
        selView.image = [UIImage imageNamed:@"popUnSel.png"];
    }
    
    [self showTotalPrice];
    
    allCellState = 2;
    
    NSInteger selCount = 0;
    
    for(NSString *selKey in selIndexArr) {
        NSString *selVal = [selIndexArr objectForKey:selKey];
        selCount += [selVal integerValue];
    }
    
    if (selCount > 0) {

        [btnComment setTitle:[NSString stringWithFormat:@"结算(%d)", selCount] forState:UIControlStateNormal];
        btnComment.enabled = YES;
        btnComment.alpha = 1;
    } else {
        
        [btnComment setTitle:@"结算" forState:UIControlStateNormal];
        btnComment.enabled = NO;
        btnComment.alpha = 0.5;
    }
    
    UIImageView *selIV = (UIImageView *)[btnSelBG viewWithTag:9];
    if (selCount != [backDataArr count]) {
        selIV.image = [UIImage imageNamed:@"popUnSel.png"];
    } else {
        selIV.image = [UIImage imageNamed:@"popSeled.png"];
    }
    
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSInteger countOfRowsToInsert = [backDataArr count];
        
        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self deleteShoppingCart:indexPath.row];
        
        // 先移出数据，再动画，否则报错
        //        [backDataArr removeAllObjects];
        //
        //        [mTableView beginUpdates];
        //
        //        [mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //
        //        [mTableView endUpdates];
        
        //        [tableView reloadData];
    }
    
}

#pragma mark - 商品数量＋1
- (void)doAddCount:(id)sender
{
    UIButton *btnAdd = (UIButton *)sender;
    
    UIView *cellContentView = [btnAdd superview];
    UITextField *numberTxt = (UITextField *)[cellContentView viewWithTag:PAY_NUMBER_TAG];
    int intVal = [numberTxt.text intValue];
    
    intVal++;
    
    numberTxt.text = [NSString stringWithFormat:@"%d", intVal];
    
    // cellCountArr 赋值
    UITableViewCell *currentCell = (UITableViewCell *)[[btnAdd superview] superview];
    NSIndexPath* indexPath = [mTableView indexPathForCell:currentCell];
    [cellCountArr setObject:numberTxt.text forKey:@(indexPath.row)];

    [self showTotalPrice];
}

#pragma mark 商品数量-1
- (void)doSubCount:(id)sender
{
    UIButton *btnSub = (UIButton *)sender;
    
    UIView *cellContentView = [btnSub superview];
    UITextField *numberTxt = (UITextField *)[cellContentView viewWithTag:PAY_NUMBER_TAG];
    int intVal = [numberTxt.text intValue];
    
    intVal --;
    
    if (intVal <= 1) {
        intVal = 1;
    }
    
    numberTxt.text = [NSString stringWithFormat:@"%d", intVal];
    
    // cellCountArr 赋值
    UITableViewCell *currentCell = (UITableViewCell *)[[btnSub superview] superview];
    NSIndexPath* indexPath = [mTableView indexPathForCell:currentCell];
    [cellCountArr setObject:numberTxt.text forKey:@(indexPath.row)];

    [self showTotalPrice];
}

#pragma mark - 删除购物车
- (void) deleteShoppingCart:(int)index
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[backDataArr[index] valueForKey:@"cart_id"] forKey:@"cart_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_deleteshoppingcart"
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
                                         
                                         [self loadShoppingCartData];
                                     }
                                 }
                             }];
     }];
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    if (viewTag == 10) {
        
        int size = [selIndexArr count];
        
        UIImageView *selIV = (UIImageView *)[btnSelBG viewWithTag:9];
        
        if ([selIV.image isEqual:[UIImage imageNamed:@"popSeled.png"] ]) {
            
            selIV.image = [UIImage imageNamed:@"popUnSel.png"];
            allCellState = 0;

            for (NSUInteger i=0; i<size; i++) {
                
                [selIndexArr setObject:@"0" forKey:@(i)];
            }
        } else {
            
            selIV.image = [UIImage imageNamed:@"popSeled.png"];
            allCellState = 1;
            
            for (NSUInteger i=0; i<size; i++) {
                
                [selIndexArr setObject:@"1" forKey:@(i)];
            }
        }
        
        [mTableView reloadData];
    }
    

    switch (allCellState) {
        case 0:
        {
            [btnComment setTitle:@"结算" forState:UIControlStateNormal];
            btnComment.enabled = NO;
            btnComment.alpha = 0.5;
        }
            break;
            
        case 1:
        {
            [btnComment setTitle:[NSString stringWithFormat:@"结算(%d)", backDataArr.count] forState:UIControlStateNormal];
            btnComment.enabled = YES;
            btnComment.alpha = 1;
        }
            break;
            
        default:
            break;
    }
    
    [self showTotalPrice];
}

- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
    
    [super setEditing:!self.editing animated:YES];
    
    [mTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (IBAction)doAction:(id)sender
{
    DLog(@"doAction");
    
    NSInteger selCount = 0;
    
    for (NSString *selKey in selIndexArr) {
        
        NSString *selVal = [selIndexArr objectForKey:selKey];
        selCount += [selVal integerValue];
    }
    
    if (selCount > 0) {
        
        [self showHUDWithText:@"支付"];
    } else {
        
        [self showHUDWithText:@"请先选择记录！"];
    }
}

- (void)showTotalPrice
{
    // total price
    double totalPrice = 0.f;
    
    for (NSString *key in selIndexArr) {
        
        if (![[selIndexArr objectForKey:key] isEqualToString:@"0"]) {
            
            NSLog(@"key: %@ value: %@", key, selIndexArr[key]);
            totalPrice += ([[cellCountArr objectForKey:key] intValue] * [[cellPriceArr objectForKey:key] doubleValue]);
        }
        
    }
    
    UILabel *totalLabel = (UILabel *)[btnCommentBG viewWithTag:11];
    totalLabel.text = [NSString stringWithFormat:@"合计:%.2f", totalPrice];
    
}

@end
