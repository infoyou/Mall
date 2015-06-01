//
//  AddressListViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "AddressListViewController.h"
#import "AddressEditViewController.h"

@interface AddressListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *backDataArr;
}

@end

@implementation AddressListViewController
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
    self.title = @"地址管理";
    
    [self adjustView];
   
    [self loadListData];
    
    [self setNaviItemEdit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNaviItemEdit
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新建"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(doAdd)];
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

#pragma mark - address list
- (void) loadListData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_getaddresslist"
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
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backDic != nil) {
                                         
                                         NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                         
                                         for(NSString * akey in msgDict) {
                                             [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                             
                                             [self.navigationController popViewControllerAnimated:YES];
                                             return;
                                         }
                                         
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

#pragma mark - UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

#pragma mark 返回tableview的行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return backDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([backDataArr count] > 0) {

        if (![@"0" isEqualToString:[backDataArr[section] valueForKey:@"default_deliver_address_flg"]]) {
            return 30.f;
        } else {
            return 0;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([backDataArr count] > 0) {
        if (![@"0" isEqualToString:[backDataArr[section] valueForKey:@"default_deliver_address_flg"]]) {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"AddressListHeadCell" owner:self options:nil] lastObject];
            
            return cell.contentView;
        }
        
        return nil;
    }
    
    return nil;
}

#pragma mark tableview的cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellSection = indexPath.section;
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"AddressListCell" owner:self options:nil] lastObject];

    UILabel *name = (UILabel *)[cell viewWithTag:10];
    UILabel *mobile = (UILabel *)[cell viewWithTag:11];
    UILabel *address = (UILabel *)[cell viewWithTag:12];
    
    UIButton *btnEdit = (UIButton *)[cell viewWithTag:113];
    UIButton *btnDel = (UIButton *)[cell viewWithTag:114];
    [self addTapGestureRecognizer:btnEdit];
    [self addTapGestureRecognizer:btnDel];
    
    NSString *nameStr = [backDataArr[cellSection] valueForKey:@"receive_name"];
    NSString *mobileStr = [backDataArr[cellSection] valueForKey:@"receive_mobile"];
    NSString *addressStr = [backDataArr[cellSection] valueForKey:@"receive_address"];
    
    name.text = nameStr;
    mobile.text = mobileStr;
    address.text = addressStr;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setDefaultAddress:[backDataArr[indexPath.section] valueForKey:@"receive_address_id"]];
}

- (void)setDefaultAddress:(NSString *)addressId
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:addressId forKey:@"address_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_setdefaultaddress"
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
                                         [self showHUDWithText:[msgDict objectForKey:akey]];
                                         return;
                                     }
                                     
                                     [self loadListData];
                                 }
                             }];
     }];

}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    UITableViewCell *clickCell = (UITableViewCell *)[[view superview] superview];
    NSIndexPath *indexPath = [mTableView indexPathForCell:clickCell];
    
    // id
    NSString *receiveAddressId = [backDataArr[indexPath.section] valueForKey:@"receive_address_id"];
    
    switch (viewTag) {
        case 113:
        {
            
            AddressEditViewController *favoriteVC = [[AddressEditViewController alloc] init];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地址列表" style:0 target:nil action:nil];
            favoriteVC.title = @"编辑收货地址";
            
            [favoriteVC updateData:receiveAddressId receiveName:[backDataArr[indexPath.section] valueForKey:@"receive_name"]
                     receiveMobile:[backDataArr[indexPath.section] valueForKey:@"receive_mobile"]
                      receiveEmail:[backDataArr[indexPath.section] valueForKey:@"email"]
                    receiveAddress:[backDataArr[indexPath.section] valueForKey:@"receive_address"]
                        locationId:[backDataArr[indexPath.section] valueForKey:@"location_id"]
                          postCode:[backDataArr[indexPath.section] valueForKey:@"post_code"]];
            
            [self.navigationController pushViewController:favoriteVC animated:YES];
        }
            break;
        
        case 114:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认删除？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                
                if (buttonIndex == 1) {
                    
                    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
                    [dataDict setObject:receiveAddressId forKey:@"address_id"];
                    
                    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_deladdress"
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
                                                         [self showHUDWithText:[msgDict objectForKey:akey]];
                                                         return;
                                                     }
                                                     
                                                     [self loadListData];
                                                 }
                                             }];
                     }];
                    
                }
            }];

        }
            break;
            
        default:
            break;
    }
    
    DLog(@"%d is touched",viewTag);
}

#pragma mark - do logic action
- (void)doAdd
{
    AddressEditViewController *favoriteVC = [[AddressEditViewController alloc] init];
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地址列表" style:0 target:nil action:nil];
    favoriteVC.title = @"添加收货地址";
    
    [favoriteVC updateData:nil
               receiveName:@""
             receiveMobile:@""
              receiveEmail:@""
            receiveAddress:@""
                locationId:@""
                  postCode:@""];
    
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

@end
