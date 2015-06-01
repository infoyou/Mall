//
//  ProductAppDelegate.h
//  Mall
//
//  Created by Adam on 14-12-4.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"


@class TabBarController;

@interface ProductAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) TabBarController *tabBarController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIWindow *window;

- (void)enterHomeVC;

@end
