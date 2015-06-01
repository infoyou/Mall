//
//  UIAlertView+Block.h
//  Mall
//
//  Created by Adam on 14/12/18.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (Block)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;
@end
