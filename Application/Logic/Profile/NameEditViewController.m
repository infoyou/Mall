
#import "NameEditViewController.h"
#import "ProductDetailViewController.h"
#import "RegistViewController.h"

@interface NameEditViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, copy) NSString *locationId;
@property (nonatomic, copy) NSString *receiveName;
@property (nonatomic, copy) NSString *receiveMobile;
@property (nonatomic, copy) NSString *receiveEmail;
@property (nonatomic, copy) NSString *receiveAddress;
@property (nonatomic, copy) NSString *postCode;

@end

@implementation NameEditViewController

@synthesize delegate;
@synthesize locationId;
@synthesize receiveName;
@synthesize receiveMobile;
@synthesize receiveEmail;
@synthesize receiveAddress;
@synthesize postCode;

@synthesize nameTxt;

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(doSave)];

    
    [self adjustView];
    
    if ([AppManager instance].userNickName != nil && [AppManager instance].userNickName.length > 0) {
        
        nameTxt.text = [AppManager instance].userNickName;
    }
    
    [nameTxt becomeFirstResponder];
}

- (void)adjustView
{
    UIButton *btnLogin = (UIButton *)[self.view viewWithTag:10];
    btnLogin.layer.cornerRadius = 2;
    [btnLogin.layer setMasksToBounds:YES];
    [btnLogin addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    btnLogin.hidden = YES;
    
    UIView *splitLine1 = (UIView *)[self.view viewWithTag:110];
    splitLine1.frame = CGRectOffset(splitLine1.frame, 0, -0.5);
    UIView *splitLine2 = (UIView *)[self.view viewWithTag:111];
    splitLine2.frame = CGRectOffset(splitLine2.frame, 0, -0.5);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkVal
{
    
    if (nameTxt.text.length > 0) {
        return YES;
    }
    
    return NO;
}

- (void)doSave
{
    
    if (![self checkVal]) {

        [self showHUDWithText:@"请检查输入信息!"];
        return;
    }
    
    [nameTxt resignFirstResponder];
    
    // 新增
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:nameTxt.text forKey:@"name"];
        
    // 编辑
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_modifymemberinfo"
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
                                             
                                             NSDictionary *optionDict = [backDic valueForKey:@"data"];
                                             int result = [[optionDict valueForKey:@"is_success"] intValue];
                                             if (result == 1) {
                                                 
                                                 [self showHUDWithText:@"操作成功" completion:^{
                                                     
                                                     [AppManager instance].userNickName = nameTxt.text;
                                                     [self.navigationController popViewControllerAnimated:YES];
                                                     
                                                 }];
                                             } else {
                                                 
                                                 [self showHUDWithText:@"操作失败" completion:^{
                                                     [self.navigationController popViewControllerAnimated:YES];
                                                 }];
                                             }
                                         }
                                         
                                     }
                                 }
                             }];
     }];

}

- (void)updateData:(NSString *)aReceiveAddressId
       receiveName:(NSString *)aReceiveName
     receiveMobile:(NSString *)aReceiveMobile
      receiveEmail:(NSString *)aReceiveEmail
    receiveAddress:(NSString *)aReceiveAddress
        locationId:(NSString *)aLocationId
          postCode:(NSString *)aPostCode
{

    self.receiveName = aReceiveName;
    self.receiveMobile = aReceiveMobile;
    self.receiveAddress = aReceiveAddress;
    self.postCode = aPostCode;
    
}

#pragma mark - text field method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != self.nameTxt) {

        [self.bgView setContentOffset:CGPointMake(0, 70) animated:YES];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField != self.nameTxt) {
        [self.bgView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    return YES;
}

#pragma mark - text view method
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView;

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [self.bgView setContentOffset:CGPointMake(0, 70) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    [self.bgView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
