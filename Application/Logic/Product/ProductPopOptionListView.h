//
//  ProductPopOptionListView.h
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "UIColor+expanded.h"

@protocol ProductPopListViewDelegate;

@interface ProductPopOptionListView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSString *_title;
    NSArray *_options;
    
    int _selectIndex;
}

@property (nonatomic, assign) id<ProductPopListViewDelegate> delegate;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions selectIndex:(int)selectIndex;
// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end


@protocol ProductPopListViewDelegate <NSObject>

- (void)popListView:(ProductPopOptionListView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)clearBackGroundView;
- (void)closePop:(id)sender;

- (void)addNewAddress:(id)sender;

@end