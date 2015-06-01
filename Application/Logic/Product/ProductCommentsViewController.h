//
//  ProductCommentsViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"
#import "ProductAppDelegate.h"

@interface ProductCommentsViewController : RootViewController

@property (weak, nonatomic) IBOutlet UITableView *productCommentsTable;

@property (weak, nonatomic) NSString *productId;

@property (weak, nonatomic) IBOutlet UIView *btnCommentBG;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@end
