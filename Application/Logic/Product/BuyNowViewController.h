//
//  BuyNowViewController.h
//  Mall
//
//  Created by Adam on 14-12-24.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@interface BuyNowViewController : RootViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *btnCommentBG;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

- (void)updateData:(NSString *)cartId skuId:(NSString *)skuId skuQty:(NSString *)skuQty skuSize:(NSString *)skuSize productImgUrl:(NSString *)productImgUrl productName:(NSString *)productName priceValue:(NSString *)priceValue;

@end
