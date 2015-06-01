
#import "BuyNowViewController.h"
#import "ProductPopOptionListView.h"
#import "ProductPopCommonOptionListView.h"
#import "AddressEditViewController.h"
#import "ProductPopAddressOptionListView.h"

#define popX   20
#define popY   80
#define popW   SCREEN_WIDTH - 2 * popX


@interface BuyNowViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ProductPopListViewDelegate, NewAddressDelegate>
{
    int row;

    UIView *receivingView;
    UIView *addreceiving;

    UITextField *receivingPostal;
    NSString *_expressName;
    NSString *_selectpayment;
    
    NSString *_userName;
    NSString *_mobileName;
    NSString *_addressName;
    
    int expressIndex;
    int payIndex;
    
    int cellClickIndex;
    
}

@property (nonatomic, retain) NSArray *expressOptionsArray;
@property (nonatomic, retain) NSMutableArray *addressOptionsArray;
@property (nonatomic, retain) NSArray *payOptionsArray;

@property (nonatomic, copy) NSString* cartId;

@property (nonatomic, copy) NSString* skuId;
@property (nonatomic, copy) NSString* skuQty;
@property (nonatomic, copy) NSString* skuSize;
@property (nonatomic, copy) NSString* productImgUrl;
@property (nonatomic, copy) NSString* productName;
@property (nonatomic, copy) NSString* priceValue;

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *phoneField;

@end

@implementation BuyNowViewController

@synthesize mTableView;
@synthesize btnCommentBG;
@synthesize btnSubmit;

@synthesize expressOptionsArray;
@synthesize addressOptionsArray;
@synthesize payOptionsArray;

@synthesize nameField, phoneField;

@synthesize cartId, skuId, skuQty, skuSize, productImgUrl, productName, priceValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{

    [self loadAddressListData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"确认订单";
    
//    [self initLisentingKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.expressOptionsArray = [NSArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"快递", @"text", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"上门自提", @"text", nil],
                           nil];
    
    self.payOptionsArray = [NSArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"货到付款", @"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"财付通", @"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"微信支付", @"text", nil],
                       nil];
    
    
}

- (void)adjustView
{
    int tableH = SCREEN_HEIGHT-50-64;
    self.mTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, tableH);
    btnCommentBG.frame = CGRectMake(0, tableH, SCREEN_WIDTH, 50);
    
    UILabel *price = (UILabel *)[btnCommentBG viewWithTag:11];
    price.text = [NSString stringWithFormat:@"%0.2f", [self.priceValue floatValue] * [self.skuQty floatValue]];
    
    btnSubmit.layer.cornerRadius = 4;
    [btnSubmit.layer setMasksToBounds:YES];
}

#pragma mark - 取消添加收货地址
- (void)addreceivingRemoveFrom
{
    [addreceiving removeFromSuperview];
}

#pragma mark - UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_expressName isEqualToString:@"快递"] || nil == _expressName)
    {
        switch (indexPath.row) {
            case 0:
            {
                return 60;
            }
                break;
                
            case 1:
            {
                return 81;
            }
                break;
                
            case 2:
            {
                return 63;
            }
                break;
                
            case 3:
            {
                return 103;
            }
                break;
                
            case 4:
            {
                return 50;
            }
                break;
                
            default:
                break;
        }
        
    } else {
        
        switch (indexPath.row) {
            case 0:
            {
                return 60;
            }
                break;
                
            case 1:
            {
                return 81;
            }
                break;
                
            case 2:
            {
                return 63;
            }
                break;
                
            case 3:
            case 4:
            {
                return 40;
            }
                break;
                
            case 5:
            {
                return 103;
            }
                break;
                
            case 6:
            {
                return 50;
            }
                break;
                
            default:
                break;
        }
    }
    
    return row;
}

#pragma mark - tableview返回得cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_expressName isEqualToString:@"快递"] || nil == _expressName) {
        return 5;
    } else {
        return 7;
    }
}

#pragma mark - 点击cell触发的事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cellClickIndex = indexPath.row;
    
    if (indexPath.row == 0) {
        
        [self showShadowView];
        
        ProductPopCommonOptionListView *popView = [[ProductPopCommonOptionListView alloc] initWithTitle:@"配送方式" options:self.expressOptionsArray selectIndex:expressIndex];
        popView.delegate = self;
        [popView showInView:APP_DELEGATE.window animated:YES];
        
    } else if (indexPath.row == 1) {
        
        [self showShadowView];
        
        ProductPopAddressOptionListView *popView = [[ProductPopAddressOptionListView alloc] initWithTitle:@"收货地址" options:self.addressOptionsArray selectIndex:expressIndex];
        popView.delegate = self;
        [popView showInView:APP_DELEGATE.window animated:YES];
        
    } else if (indexPath.row == 2) {
        
        [self showShadowView];
        
        ProductPopCommonOptionListView *popView = [[ProductPopCommonOptionListView alloc] initWithTitle:@"支付方式" options:self.payOptionsArray selectIndex:payIndex];
        popView.delegate = self;
        [popView showInView:APP_DELEGATE.window animated:YES];
        
    } else if (indexPath.row == 3) {
    } else if (indexPath.row == 4) {
    }
}

#pragma mark - 代理cell的数据显示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([_expressName isEqualToString:@"快递"] || nil == _expressName)
    {
        if (indexPath.row == 0) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PayNowDistributionCell" owner:self options:nil] lastObject];
            
            UILabel *distribution = (UILabel *)[cell viewWithTag:11];
            distribution.text = _expressName;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 1) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowAddressCell" owner:self options:nil] lastObject];
            
            UILabel *promptLabel = (UILabel *)[cell viewWithTag:9];
            UILabel *userLable = (UILabel *)[cell viewWithTag:10];
            UILabel *mobileLable = (UILabel *)[cell viewWithTag:11];
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:12];
            
            if (_userName && ![_userName isEqualToString:@""]) {
                userLable.text = _userName;
                userLable.hidden = NO;
                
                mobileLable.text = _mobileName;
                mobileLable.hidden = NO;
                
                addressLabel.text = _addressName;
                addressLabel.hidden = NO;
                
                promptLabel.hidden = YES;
            } else {
                
                userLable.hidden = YES;
                mobileLable.hidden = YES;
                addressLabel.hidden = YES;
                
                promptLabel.hidden = NO;
            }
            
            cell.backgroundColor = HEX_COLOR(@"0xfffbdb");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 2) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowPayCell" owner:self options:nil] lastObject];
            UILabel *distribution = (UILabel *)[cell viewWithTag:11];
            distribution.text = _selectpayment;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 3) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowProductCell" owner:self options:nil] lastObject];
            
            UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
            UILabel *name = (UILabel *)[cell viewWithTag:11];
            UILabel *time = (UILabel *)[cell viewWithTag:14];
            
            name.text = self.productName;
            time.text = [CommonUtils currentHourMinSecondTime];
            NSString *imageUrl = self.productImgUrl;
            
            if (imageUrl && imageUrl.length > 0) {
                
                [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    //Nothing.
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    //Nothing.
                }];
            } else {
                
                iconView.image = [UIImage imageNamed:@"placehold.png"];
            }

            return cell;
            
        } else if (indexPath.row == 4) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowTotalCell" owner:self options:nil] lastObject];
            
            UILabel *qtyLable = (UILabel *)[cell viewWithTag:10];
            qtyLable.text = [NSString stringWithFormat:@"共%@件商品", self.skuQty];
            
            UILabel *priceLable = (UILabel *)[cell viewWithTag:11];
            priceLable.text = [NSString stringWithFormat:@"合计：￥%@", [NSString stringWithFormat:@"%0.2f", [self.priceValue floatValue] * [self.skuQty floatValue]]];
            
            return cell;
        }
        
    } else {
        
        if (indexPath.row == 0) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PayNowDistributionCell" owner:self options:nil] lastObject];
            
            UILabel *distribution = (UILabel *)[cell viewWithTag:11];
            distribution.text = _expressName;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 1) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowAddressCell" owner:self options:nil] lastObject];
            
            UILabel *promptLabel = (UILabel *)[cell viewWithTag:9];
            UILabel *userLable = (UILabel *)[cell viewWithTag:10];
            UILabel *mobileLable = (UILabel *)[cell viewWithTag:11];
            UILabel *addressLabel = (UILabel *)[cell viewWithTag:12];

            if (_userName && ![_userName isEqualToString:@""]) {
                userLable.text = _userName;
                userLable.hidden = NO;
                
                mobileLable.text = _mobileName;
                mobileLable.hidden = NO;
                
                addressLabel.text = _addressName;
                addressLabel.hidden = NO;
                
                promptLabel.hidden = YES;
            } else {
                
                userLable.hidden = YES;
                mobileLable.hidden = YES;
                addressLabel.hidden = YES;
                
                promptLabel.hidden = NO;
            }
            
            cell.backgroundColor = HEX_COLOR(@"0xfffbdb");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 2) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowPayCell" owner:self options:nil] lastObject];
            
            UILabel *distribution = (UILabel *)[cell viewWithTag:11];
            distribution.text = _selectpayment;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if (indexPath.row == 3) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowUserNameCell" owner:self options:nil] lastObject];
            
            self.nameField = (UITextField *)[cell viewWithTag:10];
            self.nameField.delegate = self;
            
            return  cell;
            
        } else if (indexPath.row == 4) {
            
            cell =[[[NSBundle mainBundle] loadNibNamed:@"BuyNowUserPhoneCell" owner:self options:nil] lastObject];
            
            self.phoneField = (UITextField *)[cell viewWithTag:10];
            self.phoneField.delegate = self;
            
            return cell;
            
        } else if (indexPath.row == 5) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowProductCell" owner:self options:nil] lastObject];
            
            UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
            UILabel *name = (UILabel *)[cell viewWithTag:11];
            UILabel *time = (UILabel *)[cell viewWithTag:14];
            
            name.text = self.productName;
            time.text = [CommonUtils currentHourMinSecondTime];
            NSString *imageUrl = self.productImgUrl;
            
            if (imageUrl && imageUrl.length > 0) {
                
                [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    //Nothing.
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    //Nothing.
                }];
            } else {
                
                iconView.image = [UIImage imageNamed:@"placehold.png"];
            }

            return cell;
            
        } else if (indexPath.row == 6) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowTotalCell" owner:self options:nil] lastObject];
            
            UILabel *qtyLable = (UILabel *)[cell viewWithTag:10];
            qtyLable.text = [NSString stringWithFormat:@"共%@件商品", self.skuQty];
            
            UILabel *priceLable = (UILabel *)[cell viewWithTag:11];
            priceLable.text = [NSString stringWithFormat:@"合计：￥%@", [NSString stringWithFormat:@"%0.2f", [self.priceValue floatValue] * [self.skuQty floatValue]]];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - ProductPopListViewDelegate method
- (void)closePop:(id)sender
{
    if(receivingView != nil) {
        [receivingView removeFromSuperview];
    }
    
    [self.backView removeFromSuperview];
}

- (void)addNewAddress:(id)sender
{
    [self.backView removeFromSuperview];
    
    AddressEditViewController *favoriteVC = [[AddressEditViewController alloc] init];
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:0 target:nil action:nil];
    favoriteVC.title = @"添加收货地址";
    favoriteVC.delegate = self;
    
    [favoriteVC updateData:nil
               receiveName:@""
             receiveMobile:@""
              receiveEmail:@""
            receiveAddress:@""
                locationId:@""
                  postCode:@""];
    
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

- (void)popListView:(ProductPopOptionListView *)popListView didSelectedIndex:(NSInteger)popIndex
{

    switch (cellClickIndex) {
        case 0:
        {
            expressIndex = popIndex;
            _expressName = [[self.expressOptionsArray objectAtIndex:popIndex] objectForKey:@"text"];
        }
            break;
            
        case 1:
        {

            _userName = [[self.addressOptionsArray objectAtIndex:popIndex] objectForKey:@"user"];
            _mobileName = [[self.addressOptionsArray objectAtIndex:popIndex] objectForKey:@"mobile"];
            _addressName = [[self.addressOptionsArray objectAtIndex:popIndex] objectForKey:@"address"];
        }
            break;
            
        case 2:
        {
            payIndex = popIndex;
            _selectpayment = [[self.payOptionsArray objectAtIndex:popIndex] objectForKey:@"text"];
        }
            break;
            
        default:
            break;
    }
    
    [self.mTableView reloadData];
    [self.backView removeFromSuperview];
}

- (void)clearBackGroundView
{
    DLog(@"You have cancelled");
    
    [self.backView removeFromSuperview];
}

- (IBAction)doConfim:(id)sender
{
   /*
    输入参数说明:
    carts:购物车集合
    cart_id: 购物车id
    sku_id:商品sku_id
    sku_qty:商品数量
    size:商品的尺寸
    delivery_mode:配送方式（1：快递送货，2：上门提货）
    paytype:支付方式,1：货到付款 2：在线支付 3:到店支付
    store_id:门店id
    name:收货人姓名
    phone:收货人手机号码
    email:收货人邮箱（选填）
    remark:备注
    article_delivery_address：收货地址（当收货方式为送货上门时，必填）
    order_type:订单类型 1:普通订单，2:到店体验订单，3:服务订单
    subpaytype：如果是在线支付的话，要选择子支付方式，1：支付宝  2：财付通  3:微信支付
    arrive_store_time：到点体验时间，（如果选择了到店体验，则此参数必填）
    */

    NSMutableDictionary *cartsDict = [NSMutableDictionary dictionary];
    [cartsDict setObject:self.cartId forKey:@"cart_id"];
    [cartsDict setObject:self.skuId forKey:@"sku_id"];
    [cartsDict setObject:self.skuQty forKey:@"sku_qty"];
    [cartsDict setObject:self.skuSize forKey:@"size"];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[NSString stringWithFormat:@"[%@]", [cartsDict JSONString]] forKey:@"carts"];
    
    // 1：快递送货，2：上门提货
    [dataDict setObject:@"1" forKey:@"delivery_mode"];
    // 1：货到付款 2：在线支付 3:到店支付
    [dataDict setObject:@"1" forKey:@"paytype"];
    [dataDict setObject:@"eceA" forKey:@"store_id"];
    [dataDict setObject:@"Adam" forKey:@"name"];
    [dataDict setObject:@"13524010590" forKey:@"phone"];
    [dataDict setObject:@"" forKey:@"email"]; // 选填
    
    // 1:普通订单，2:到店体验订单，3:服务订单
    [dataDict setObject:@"1" forKey:@"order_type"];
    // 如果是在线支付的话，要选择子支付方式，1：支付宝  2：财付通  3:微信支付
    [dataDict setObject:@"1" forKey:@"subpaytype"];
    // 备注
    [dataDict setObject:@"" forKey:@"remark"];
    // 到点体验时间，（如果选择了到店体验，则此参数必填
    [dataDict setObject:@"2015-1-12 00:00:00" forKey:@"arrive_store_time"];
    // 收货地址（当收货方式为送货上门时，必填）
    [dataDict setObject:@"Shanghai2205" forKey:@"article_delivery_address"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_order_createorder"
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
                                         
                                         NSString *orderId = [[backDic valueForKey:@"data"] valueForKey:@"order_id"];
                                         
                                         if (orderId != nil && orderId.length > 0) {
                                             
                                             [self showHUDWithText:@"下单成功"];
                                         }
                                     }
                                 }
                             }];
     }];

}

- (void) updateData:(NSString *)aCartId skuId:(NSString *)aSkuId skuQty:(NSString *)aSkuQty skuSize:(NSString *)aSkuSize productImgUrl:(NSString *)aProductImgUrl productName:(NSString *)aProductName priceValue:(NSString *)aPriceValue
{
    
    self.cartId = aCartId;
    self.skuId = aSkuId;
    self.skuQty = aSkuQty;
    self.skuSize = aSkuSize;
    self.productImgUrl = aProductImgUrl;
    self.productName = aProductName;
    self.priceValue = aPriceValue;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.nameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    
    [receivingView removeFromSuperview];
    [self.backView removeFromSuperview];
    
    [self.view endEditing:YES];
}

#pragma mark - address list
- (void)loadAddressListData
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
                                        //  [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                        //  [self.navigationController popViewControllerAnimated:YES];
                                             return;
                                         }
                                         
                                         NSMutableArray *addressDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         
                                         int addressCount = [addressDataArr count];
                                         if (addressCount > 0) {
                                             
                                             self.addressOptionsArray = [NSMutableArray array];
                                             
                                             for (int i=0; i<addressCount; i++) {
                                                 
                                                 NSString *receiveAddressId = [addressDataArr[i] valueForKey:@"receive_address_id"];
                                                 NSString *receiveName = [addressDataArr[i] valueForKey:@"receive_name"];
                                                 NSString *receiveAddress = [addressDataArr[i] valueForKey:@"receive_address"];
                                                 NSString *receiveMobile = [addressDataArr[i] valueForKey:@"receive_mobile"];
                                                 
                                                 [self.addressOptionsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:receiveAddressId, @"id",
                                                                                      receiveName, @"user",
                                                                                      receiveMobile, @"mobile",
                                                                                      receiveAddress, @"address", nil]];
                                             }
                                             
                                         }
                                     }
                                 }
                             }];
     }];
}

#pragma mark - UITextFieldDelegate method
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.mTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    [self.mTableView setContentOffset:CGPointMake(0, 70) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self.mTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    return YES;
}

#pragma mark - NewAddressDelegate method
- (void)updateAddressUser:(NSString *)addressUser
             addressPhone:(NSString *)addressPhone
              addressName:(NSString *)addressName
{
    _userName = addressUser;
    _mobileName = addressPhone;
    _addressName = addressName;
    
    [self.mTableView reloadData];
}

@end
