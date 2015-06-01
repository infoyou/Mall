
#import "BaseNavigationController.h"
#import "RootViewController.h"
#import "ProductListViewController.h"
#import "ICSDrawerController.h"

@interface BaseNavigationController() </*ICSDrawerControllerChild,*/ ICSDrawerControllerPresenting>

@end

@implementation BaseNavigationController

#pragma mark - user action
- (void)back:(id)sender {
    
    [self popViewControllerAnimated:YES];
}

#pragma mark - lifecycle methods
- (id)initWithRootViewController:(UIViewController *)rootViewController {
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustNaviStyle];
}

- (void)adjustNaviStyle {
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor redColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:20.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
}

- (void)clickType:(NSString*)aKeyWord
       classIdStr:(NSString *)aClassIdStr
     classShowStr:(NSString *)aClassShowStr
{
    
    [((ProductListViewController*)self.viewControllers[0]) clickType:aKeyWord classIdStr:aClassIdStr classShowStr:aClassShowStr];
}

#pragma mark - ICSDrawerControllerPresenting method

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

@end
