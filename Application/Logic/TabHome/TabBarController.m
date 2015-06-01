//
//  TabBarController.m
//  TabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import "TabBarController.h"
#import "TabBarItem.h"
#import "ICSDrawerController.h"
#import "BaseNavigationController.h"

static TabBarController *mTabBarController;

@implementation UIViewController (TabBarControllerSupport)

- (TabBarController *)mTabBarController
{
	return mTabBarController;
}

@end

@interface TabBarController (private)
- (void)displayViewAtIndex:(NSUInteger)index;
@end

@implementation TabBarController
@synthesize delegate = _delegate;
@synthesize selectedViewController = _selectedViewController;
@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabBarHidden = _tabBarHidden;
@synthesize animateDriect;

#pragma mark - lifecycle
- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr
{
	self = [super init];
    
	if (self != nil)
	{
		_viewControllers = [[NSMutableArray arrayWithArray:vcs] retain];
		
		_containerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		_transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _containerView.frame.size.height + 28)];
//		_transitionView.backgroundColor =  [UIColor groupTableViewBackgroundColor];
		
		_tabBar = [[TabBarItem alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kTabBarHeight, SCREEN_WIDTH, kTabBarHeight) buttonImages:arr];
        
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        splitView.backgroundColor = HEX_COLOR(@"0xe1e1e1");
        [_tabBar addSubview:splitView];
        _tabBar.backgroundColor = [UIColor whiteColor];
        
        _tabBar.delegate = self;
        mTabBarController = self;
        animateDriect = 0;
	}
    
	return self;
}

- (void)loadView
{
	[super loadView];
    
    _transitionView.backgroundColor = [UIColor blackColor];
	[_containerView addSubview:_transitionView];
    
	[_containerView addSubview:_tabBar];
    
	self.view = _containerView;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.selectedIndex = 0;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	_tabBar = nil;
	_viewControllers = nil;
}

- (void)dealloc 
{
    _tabBar.delegate = nil;
	[_tabBar release];
    [_containerView release];
    [_transitionView release];
	[_viewControllers release];
    
    [super dealloc];
}

#pragma mark - instant methods

- (TabBarItem *)tabBar
{
	return _tabBar;
}

- (BOOL)tabBarTransparent
{
	return _tabBarTransparent;
}

- (void)setTabBarTransparent:(BOOL)yesOrNo
{
	if (yesOrNo == YES)
	{
		_transitionView.frame = _containerView.bounds;
	} else {
		_transitionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _containerView.frame.size.height - kTabBarHeight);
	}
}

- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated
{
	if (yesOrNO == YES)
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height)
		{
			return;
		}
	}
	else 
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height - kTabBarHeight)
		{
			return;
		}
	}
	
	if (animated == YES)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		[UIView commitAnimations];
	}
	else 
	{
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else 
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
	}
}

- (NSUInteger)selectedIndex
{
	return _selectedIndex;
}

- (UIViewController *)selectedViewController
{
    return [_viewControllers objectAtIndex:_selectedIndex];
}

-(void)setSelectedIndex:(NSUInteger)index
{
    [self displayViewAtIndex:index];
    [_tabBar selectTabAtIndex:index];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= [_viewControllers count])
    {
        return;
    }
    // Remove view from superview.
    [[(UIViewController *)[_viewControllers objectAtIndex:index] view] removeFromSuperview];
    // Remove viewcontroller in array.
    [_viewControllers removeObjectAtIndex:index];
    // Remove tab from tabbar.
    [_tabBar removeTabAtIndex:index];
}

- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    [_viewControllers insertObject:vc atIndex:index];
    [_tabBar insertTabWithImageDic:dict atIndex:index];
}

#pragma mark - Private methods
- (void)displayViewAtIndex:(NSUInteger)index
{
    // Before change index, ask the delegate should change the index.
    if ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) 
    {
        if (![_delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:index]])
        {
            return;
        }
    }
    
    // If target index if equal to current index, do nothing.
    if (_selectedIndex == index && [[_transitionView subviews] count] != 0) 
    {
        return;
    }

    _selectedIndex = index;
    [self dismissViewControllerAnimated:NO completion:nil];
	UIViewController *selectedVC = [self.viewControllers objectAtIndex:index];
	
	selectedVC.view.frame = _transitionView.frame;
	if ([selectedVC.view isDescendantOfView:_transitionView])
	{
		[_transitionView bringSubviewToFront:selectedVC.view];
        
        RootViewController *tabVC = nil;
        
        // 调用Table View Controller viewWillAppear
        if (index != 1) {

            UINavigationController *selNav = (UINavigationController *)selectedVC;
            tabVC = (RootViewController *)[[selNav viewControllers] objectAtIndex:0];
        } else {
            
            tabVC = (RootViewController *)[((BaseNavigationController *)((ICSDrawerController *)selectedVC).centerViewController) viewControllers][0];
        }
        
        [tabVC viewWillAppear:YES];
        
	} else {
		[_transitionView addSubview:selectedVC.view];
	}

}

#pragma mark - tabBar delegates
- (void)tabBar:(TabBarItem *)tabBar didSelectIndex:(NSInteger)index
{
	if (self.selectedIndex == index) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        [nav popViewControllerAnimated:YES];
    } else {
        [self displayViewAtIndex:index];
    }
}

@end
