//
//  ExperienceCartCell.h
//  Mall
//
//  Created by Adam on 14-12-25.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExperienceCartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selImg;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productDesc;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *price;

@end
