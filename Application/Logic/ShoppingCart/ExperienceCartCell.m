//
//  ExperienceCartCell.m
//  Mall
//
//  Created by Adam on 14-12-25.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ExperienceCartCell.h"

@implementation ExperienceCartCell
{
    BOOL m_checked;
}

@synthesize selImg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
    
    [super setEditing:editting animated:animated];
    
    if (editting)
    {
        if (selImg == nil)
        {
            selImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unselected.png"]];
            [self addSubview:selImg];
        }
        
        [self setChecked:m_checked];
        selImg.center = CGPointMake(-CGRectGetWidth(selImg.frame) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
//        [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
//                                alpha:1.0 animated:animated];
        
    } else {
        
        m_checked = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundView = nil;
        
        if (selImg)
        {
//            [self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(selImg.frame) * 0.5,
//                                                      CGRectGetHeight(self.bounds) * 0.5)
//                                    alpha:1.0
//                                 animated:animated];
        }
    }
}

- (void) setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        
        selImg.center = pt;
        selImg.alpha = alpha;
        
        [UIView commitAnimations];
    } else {
        selImg.center = pt;
        selImg.alpha = alpha;
    }
}


- (void) setChecked:(BOOL)checked
{
    if (checked)
    {
        selImg.image = [UIImage imageNamed:@"popSeled.png"];
//        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    } else {
        selImg.image = [UIImage imageNamed:@"popUnSel.png"];
//        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    m_checked = checked;
}

@end
