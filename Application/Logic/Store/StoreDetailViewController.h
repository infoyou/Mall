//
//  StoreDetailViewController.h
//  Mall
//
//  Created by Adam on 14-12-22.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface StoreDetailViewController : RootViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *slideImages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSString *storeId;

@property (nonatomic, weak) IBOutlet UITableView *mTableView;

@end
