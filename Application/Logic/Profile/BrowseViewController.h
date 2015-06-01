//
//  BrowseViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"
#import "ProductAppDelegate.h"

@interface BrowseViewController : RootViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (weak, nonatomic) NSString *product_id;

@property (weak, nonatomic) IBOutlet UIView *btnCommentBG;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@end
