
#import "RegistViewController.h"
#import "ProductDetailViewController.h"
#import "PooCodeView.h"

@interface RegistViewController ()
{
    PooCodeView *codeView;
}
@end

@implementation RegistViewController
@synthesize phoneTxt;
@synthesize pswdTxt;
@synthesize codeTxt;
@synthesize codeImg;

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
    
    self.title = @"注册";

    [self adjustView];
}

- (void)adjustView
{
    UIButton *btnLogin = (UIButton *)[self.view viewWithTag:10];
    btnLogin.layer.cornerRadius = 2;
    [btnLogin.layer setMasksToBounds:YES];
    [btnLogin addTarget:self action:@selector(doRegist) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *splitLine1 = (UIView *)[self.view viewWithTag:110];
    splitLine1.frame = CGRectOffset(splitLine1.frame, 0, -0.5);
    UIView *splitLine2 = (UIView *)[self.view viewWithTag:111];
    splitLine2.frame = CGRectOffset(splitLine2.frame, 0, -0.5);
    UIView *splitLine3 = (UIView *)[self.view viewWithTag:112];
    splitLine3.frame = CGRectOffset(splitLine3.frame, 0, -0.5);
    
    UIImageView *codeImgView = (UIImageView *)[self.view viewWithTag:14];
    codeImgView.hidden = YES;
    
    codeView = [[PooCodeView alloc] initWithFrame:codeImgView.frame];
    [self.view addSubview:codeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkVal
{

    if (![[codeTxt.text lowercaseString] isEqualToString:[codeView.changeString lowercaseString]]) {
        [self showTimeAlert:@"提示" message:@"验证码错误"];
        return NO;
    }
    
    if (phoneTxt.text > 0 && pswdTxt.text.length > 0) {
        return YES;
    } else {
        [self showTimeAlert:@"提示" message:@"请输入用户名和密码!"];
        return NO;
    }
    
    return NO;
}

- (void)doRegist
{
    
    [phoneTxt resignFirstResponder];
    [pswdTxt resignFirstResponder];
    [codeTxt resignFirstResponder];
    
    if (![self checkVal]) {
        return;
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:phoneTxt.text forKey:@"phone"];
    [dataDict setObject:pswdTxt.text forKey:@"password"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_register"
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
                                         
                                         NSDictionary *msgDict = [backDic valueForKey:@"msg"];
                                         
                                         for(NSString * akey in msgDict) {
                                             [self showTimeAlert:@"提示" message:[msgDict objectForKey:akey]];
                                             
                                             return;
                                         }

                                         NSDictionary *userDict = [backDic valueForKey:@"data"];
                                         
                                         [AppManager instance].userId = [userDict valueForKey:@"member_id"];
                                        
                                       [self.navigationController popViewControllerAnimated:YES];
//                                       [self.navigationController popToRootViewControllerAnimated:YES];
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
