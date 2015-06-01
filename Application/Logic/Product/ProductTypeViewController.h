//
//  ProductTypeViewController.h
//  Mall
//
//  Created by Adam on 14-12-23.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ICSDrawerController.h"
#import "BaseNavigationController.h"
#import "CommonUtils.h"
#import "ProductAppDelegate.h"
#import "UIColor+expanded.h"

#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface ProductTypeViewController : UIViewController <ICSDrawerControllerChild, ICSDrawerControllerPresenting, UISearchBarDelegate>

@property (nonatomic, weak) ICSDrawerController *drawer;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *mSearchCancelBtn;


@end
