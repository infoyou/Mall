//
//  LoginViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface LoginViewController : RootViewController

@property (nonatomic, strong) IBOutlet UITextField *phoneTxt;
@property (nonatomic, strong) IBOutlet UITextField *pswdTxt;
@property (nonatomic, strong) IBOutlet UILabel *registLabel;
@property (nonatomic, strong) IBOutlet UILabel *findPswdLabel;

@end
