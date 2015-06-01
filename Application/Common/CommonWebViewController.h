//
//  CommonWebViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "UIWebView+Blocks.h"

@interface CommonWebViewController : RootViewController <UIWebViewDelegate>
{
}

@property (nonatomic, retain) NSString *strUrl;
@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) UIWebView *mWebView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
