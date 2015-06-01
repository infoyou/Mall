//
//  TabBarController.h
//  TabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "TabBarItem.h"

@class UITabBarController;
@protocol TabBarControllerDelegate;

@interface TabBarController : UIViewController <TabBarDelegate>
{
	TabBarItem *_tabBar;
	UIView      *_containerView;
	UIView		*_transitionView;
	id<TabBarControllerDelegate> _delegate;
	NSMutableArray *_viewControllers;
	NSUInteger _selectedIndex;
	
	BOOL _tabBarTransparent;
	BOOL _tabBarHidden;
    
    NSInteger animateDriect;
}

@property(nonatomic, copy) NSMutableArray *viewControllers;
@property(nonatomic, readonly) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;

// Apple is readonly
@property (nonatomic, readonly) TabBarItem *tabBar;
@property(nonatomic,assign) id<TabBarControllerDelegate> delegate;


// Default is NO, if set to YES, content will under tabbar
@property (nonatomic) BOOL tabBarTransparent;
@property (nonatomic) BOOL tabBarHidden;

@property(nonatomic,assign) NSInteger animateDriect;

- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr;

- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated;

// Remove the viewcontroller at index of viewControllers.
- (void)removeViewControllerAtIndex:(NSUInteger)index;

// Insert an viewcontroller at index of viewControllers.
- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;

@end


@protocol TabBarControllerDelegate <NSObject>

@optional
- (BOOL)tabBarController:(TabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
@end

@interface UIViewController (TabBarControllerSupport)
@property(nonatomic, readonly) TabBarController *tabBarController;

@end

