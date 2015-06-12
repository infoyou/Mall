//
//  ProductAppDelegate.m
//  Mall
//
//  Created by Adam on 14-12-4.
//  Copyright (c) 2014年 ___MJ___. All rights reserved.
//

#import "ProductAppDelegate.h"
#import "HomeViewController.h"
#import "ShoppingCartHomeViewController.h"
#import "ProfileViewController.h"
#import "ProductListViewController.h"
#import "ICSDrawerController.h"
#import "ProductTypeViewController.h"
#import "BaseNavigationController.h"
#import "MobClick.h"

@implementation ProductAppDelegate

@synthesize tabBarController;
@synthesize imageView;
@synthesize window;

- (void)regist3rd
{
    /*
     REALTIME = 0,       //实时发送
     BATCH = 1,          //启动发送
     SENDDAILY = 4,      //每日发送
     SENDWIFIONLY = 5,   //仅在WIFI下启动时发送
     SEND_INTERVAL = 6,  //按最小间隔发送
     SEND_ON_EXIT = 7    //退出或进入后台时发送
     */
    
    [MobClick startWithAppkey:@"549a235dfd98c55b770003c7" reportPolicy:BATCH channelId:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[AppManager instance] prepareData];
    [self regist3rd];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self enterHomeVC];
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)enterHomeVC {
    
    // Home
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    BaseNavigationController *homeNav = [[BaseNavigationController alloc] initWithRootViewController:homeVC];
    
    // Product
    ProductListViewController *productVC = [[ProductListViewController alloc] init];
    BaseNavigationController *productNav = [[BaseNavigationController alloc] initWithRootViewController:productVC];
    
    // 侧滑
    ProductTypeViewController *typeVC = [[ProductTypeViewController alloc] init];
    ICSDrawerController *drawerVC = [[ICSDrawerController alloc] initWithLeftViewController:typeVC
                                                                       centerViewController:productNav];
    productVC.drawer = drawerVC;
    
    // Shopping Cart
    ShoppingCartHomeViewController *shoppingCartVC = [[ShoppingCartHomeViewController alloc] init];
    BaseNavigationController *shoppingNav = [[BaseNavigationController alloc] initWithRootViewController:shoppingCartVC];
    
    // Profile
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    BaseNavigationController *profileNav = [[BaseNavigationController alloc] initWithRootViewController:profileVC];
    
    NSArray *tabVCArray = [NSArray arrayWithObjects:homeNav, drawerVC, shoppingNav, profileNav, nil];
    
    NSMutableDictionary *imgDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [imgDic setObject:[UIImage imageNamed:@"Tabbar1.png"] forKey:@"Default"];
    [imgDic setObject:[UIImage imageNamed:@"Tabbar1.png"] forKey:@"Highlighted"];
    [imgDic setObject:[UIImage imageNamed:@"Tabbar1_sel.png"] forKey:@"Seleted"];
    
    NSMutableDictionary *imgDic2 = [NSMutableDictionary dictionaryWithCapacity:3];
    [imgDic2 setObject:[UIImage imageNamed:@"Tabbar2.png"] forKey:@"Default"];
    [imgDic2 setObject:[UIImage imageNamed:@"Tabbar2.png"] forKey:@"Highlighted"];
    [imgDic2 setObject:[UIImage imageNamed:@"Tabbar2_sel.png"] forKey:@"Seleted"];
    
    NSMutableDictionary *imgDic3 = [NSMutableDictionary dictionaryWithCapacity:3];
    [imgDic3 setObject:[UIImage imageNamed:@"Tabbar3.png"] forKey:@"Default"];
    [imgDic3 setObject:[UIImage imageNamed:@"Tabbar3.png"] forKey:@"Highlighted"];
    [imgDic3 setObject:[UIImage imageNamed:@"Tabbar3_sel.png"] forKey:@"Seleted"];
    
    NSMutableDictionary *imgDic4 = [NSMutableDictionary dictionaryWithCapacity:3];
    [imgDic4 setObject:[UIImage imageNamed:@"Tabbar4.png"] forKey:@"Default"];
    [imgDic4 setObject:[UIImage imageNamed:@"Tabbar4.png"] forKey:@"Highlighted"];
    [imgDic4 setObject:[UIImage imageNamed:@"Tabbar4_sel.png"] forKey:@"Seleted"];
    
    NSArray *imgArr = [NSArray arrayWithObjects:imgDic, imgDic2, imgDic3, imgDic4, nil];
    
    self.tabBarController = [[TabBarController alloc] initWithViewControllers:tabVCArray imageArray:imgArr];
    
    [self.window addSubview:self.tabBarController.view];
    self.window.rootViewController = self.tabBarController;
}

- (void)button:(UIButton *)sender
{
    if (sender.selected ==NO)
    {
        
        sender.selected = YES;
        imageView.hidden = NO;
    } else {
        
        sender.selected = NO;
        imageView.hidden = YES;
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    if (viewController.hidesBottomBarWhenPushed)
    {
        [self.tabBarController hidesTabBar:YES animated:YES];
    } else {
        [self.tabBarController hidesTabBar:NO animated:YES];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
