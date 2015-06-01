//
//  TabBarItem.h
//  TabBarController
//
//  Created by zhang on 12-10-10.
//  Copyright (c) 2012年 jclt. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@protocol TabBarDelegate;

@interface TabBarItem : UIView
{
	UIImageView *_backgroundView;
	id<TabBarDelegate> _delegate;
	NSMutableArray *_buttons;
}

@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, assign) id<TabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *buttons;


- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray;
- (void)selectTabAtIndex:(NSInteger)index;
- (void)removeTabAtIndex:(NSInteger)index;
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)setBackgroundImage:(UIImage *)img;

@end
@protocol TabBarDelegate<NSObject>
@optional
- (void)tabBar:(TabBarItem *)tabBar didSelectIndex:(NSInteger)index; 
@end
