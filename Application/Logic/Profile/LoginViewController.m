
#import "LoginViewController.h"
#import "ProductDetailViewController.h"
#import "RegistViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize phoneTxt;
@synthesize pswdTxt;
@synthesize registLabel;
@synthesize findPswdLabel;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"登录";

    [self adjustView];
}

- (void)adjustView
{
    UIButton *btnLogin = (UIButton *)[self.view viewWithTag:10];
    btnLogin.layer.cornerRadius = 2;
    [btnLogin.layer setMasksToBounds:YES];
    [btnLogin addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *splitLine1 = (UIView *)[self.view viewWithTag:110];
    splitLine1.frame = CGRectOffset(splitLine1.frame, 0, -0.5);
    UIView *splitLine2 = (UIView *)[self.view viewWithTag:111];
    splitLine2.frame = CGRectOffset(splitLine2.frame, 0, -0.5);

    [self addTapGestureRecognizer:registLabel];
    
    [self addTapGestureRecognizer:findPswdLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkVal
{

//    phoneTxt.text = @"13524010590";
//    pswdTxt.text = @"123321";
    
//    phoneTxt.text = @"13472460952";
//    pswdTxt.text = @"111111";
    
    if (phoneTxt.text > 0 && pswdTxt.text.length > 0) {
        return YES;
    }
    
    return NO;
}

- (void)doLogin
{
    
    [phoneTxt resignFirstResponder];
    [pswdTxt resignFirstResponder];
    
    if (![self checkVal]) {
//        [self showTimeAlert:@"提示" message:@"请输入用户名和密码!"];
        [self showHUDWithText:@"请输入用户名和密码!"];
        return;
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:phoneTxt.text forKey:@"phone"];
    [dataDict setObject:pswdTxt.text forKey:@"password"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_login"
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
                                         
                                         // msg
                                         NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                         for(NSString * akey in msgDict) {
                                             [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                             
                                             return;
                                         }

                                         NSDictionary *dataDict = OBJ_FROM_DIC(backDic, @"data");
                                         if ([dataDict count] > 0) {

                                             NSDictionary *userDict = [backDic valueForKey:@"data"];
                                             
                                             [AppManager instance].userId = [userDict valueForKey:@"member_id"];
                                             [AppManager instance].userImageUrl = [userDict valueForKey:@"thumbnail_url"];
                                             [AppManager instance].userName = [userDict valueForKey:@"member_name"];
                                             [AppManager instance].userNickName = [userDict valueForKey:@"nick_name"];
                                             [AppManager instance].userMobile = [userDict valueForKey:@"mobile"];
                                             [AppManager instance].userPoint = [userDict valueForKey:@"point"];
                                             [AppManager instance].userDefaultAddress = [userDict valueForKey:@"default_address"];
                                             [AppManager instance].userProvince = [userDict valueForKey:@"province"];
                                             [AppManager instance].userCity = [userDict valueForKey:@"city"];
                                             
                                             [AppManager instance].profileCellNumberDict = [userDict valueForKey:@"extend"];
                                         }
                                         
                                         [self showHUDWithText:@"登录成功" completion:^{
                                             [[AppManager instance] rememberUserData:[AppManager instance].userId
                                                                            userName:[AppManager instance].userName
                                                                            nickName:[AppManager instance].userNickName
                                                                              avator:[AppManager instance].userImageUrl
                                                                               point:[AppManager instance].userPoint];
                                             
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }];
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
    
    switch (viewTag) {
        case 13:
        {
         
            RegistViewController *registVC = [[RegistViewController alloc] init];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:0 target:nil action:nil];
            [self.navigationController pushViewController:registVC animated:YES];

        }
            break;
         
        case 14:
        {
            
        }
            break;
            
        default:
            break;
    }
}

@end
