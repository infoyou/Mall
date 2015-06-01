//
//  ShoppingCartHomeViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ShoppingCartHomeViewController.h"
#import "ShoppingCartViewController.h"
#import "ExperienceViewController.h"
#import "HomeViewController.h"

@interface ShoppingCartHomeViewController ()
{
    
    int segmentIndex;
}

@end

@implementation ShoppingCartHomeViewController

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
    
    [self showOrHideTabBar:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"主页"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(goHome)];
    
    [self addSegmentedControl];
    
    // 到店体验
    ExperienceViewController *experienceCartVC = [[ExperienceViewController alloc] init];
    [self.view addSubview:experienceCartVC.view];
}

- (void)addSegmentedControl
{
    // SegmentedControl
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(77, 15, 166, 32)];
    segmentedControl.tintColor = [UIColor whiteColor];
    
    // All
    [segmentedControl insertSegmentWithTitle:@"到店体验"
                                     atIndex:0
                                    animated:YES];
    // My bookshell
    [segmentedControl insertSegmentWithTitle:@"购物车"
                                     atIndex:1
                                    animated:YES];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = NO;
    segmentedControl.multipleTouchEnabled = NO;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *unselectedBackgroundImage = [[CommonUtils createImageWithColor:[UIColor clearColor]]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [[UISegmentedControl appearance] setBackgroundImage:unselectedBackgroundImage
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    
    UIImage *selectedBackgroundImage = [[CommonUtils createImageWithColor:[UIColor grayColor] withRect:CGRectMake(0.0f, 0.0f, 85, 32.0f)]
                                        resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [[UISegmentedControl appearance] setBackgroundImage:selectedBackgroundImage
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
    
    NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Helvetica" size:15.0f],
                                        UITextAttributeFont,
                                        [UIColor whiteColor],
                                        UITextAttributeTextColor,
                                        [UIColor clearColor],
                                        UITextAttributeTextShadowColor, nil];
    [segmentedControl setTitleTextAttributes:selectedAttributes
                                    forState:UIControlStateSelected];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"Helvetica" size:15.0f],
                                      UITextAttributeFont,
                                      [UIColor whiteColor],
                                      UITextAttributeTextColor,
                                      [UIColor clearColor],
                                      UITextAttributeTextShadowColor, nil];
    [segmentedControl setTitleTextAttributes:normalAttributes
                                    forState:UIControlStateNormal];
    
    segmentedControl.layer.masksToBounds = YES;
    segmentedControl.layer.cornerRadius = 6;
    segmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
    segmentedControl.layer.borderWidth = 1.f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = segmentedControl;

}

#pragma mark - Segment Action
- (void)segmentAction:(UISegmentedControl *)Seg {
    
    segmentIndex = Seg.selectedSegmentIndex;
    DLog(@"Index %i", segmentIndex);
    
    switch (segmentIndex) {
            
        case 0:
            {
                
                // 刷新 体验列表
                ExperienceViewController *experienceCartVC = [[ExperienceViewController alloc] init];
                
                [self.view addSubview:experienceCartVC.view];
//                [self.navigationController pushViewController:experienceCartVC animated:YES];
            }
            break;
            
        case 1:
            {
                // 刷新 购物列表
                ShoppingCartViewController *shoppingCartVC = [[ShoppingCartViewController alloc] init];
                
                [self.view addSubview:shoppingCartVC.view];
//                [self.navigationController pushViewController:shoppingCartVC animated:YES];
            }
            break;
            
        default:
            break;
    }
    
}

- (void)goHome
{

    [(ProductAppDelegate*)APP_DELEGATE enterHomeVC];
    [((ProductAppDelegate*)APP_DELEGATE).tabBarController setSelectedIndex:0];
    
}

@end
