//
//  ProductDetailViewController.h
//  Mall
//
//  Created by Adam on 14-12-9.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface ProductDetailViewController : RootViewController

@property (nonatomic, strong) UIScrollView  *popScrollView;
@property (nonatomic, strong) UIPageControl *popPageControl;

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, copy) NSString *productId;

@property (nonatomic, weak) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *carBG;

@end
