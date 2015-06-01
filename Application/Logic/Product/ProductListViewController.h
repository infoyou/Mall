//
//  ProductListViewController.h
//  Mall
//
//  Created by Adam on 14-12-10.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"
#import "ICSDrawerController.h"
#import "TMQuiltView.h"

@interface ProductListViewController : RootViewController <TMQuiltViewDataSource, TMQuiltViewDelegate, EGORefreshTableDelegate, ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    
    NSMutableArray *tbdataAry;
    
}

@property (nonatomic, weak) ICSDrawerController *drawer;
@property (nonatomic, copy) NSString *keyWord;

- (void)clickType:(NSString*)aKeyWord classIdStr:(NSString *)aClassIdStr classShowStr:(NSString *)aClassShowStr;

- (void)doProductItem;
- (void)doProductSearch;

@end
