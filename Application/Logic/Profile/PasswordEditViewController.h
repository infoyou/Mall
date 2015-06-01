//
//  PasswordEditViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface PasswordEditViewController : RootViewController

@property (strong, nonatomic) IBOutlet UIScrollView *bgView;
@property (nonatomic, strong) IBOutlet UITextField *oldPswdTxt;
@property (nonatomic, strong) IBOutlet UITextField *pswdTxt;
@property (nonatomic, strong) IBOutlet UITextField *confimPswdTxt;

@end
