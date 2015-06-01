//
//  ProductPopAddressOptionListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "ProductPopAddressOptionListView.h"

#define POP_X             25.
#define POP_HEARD_H       40.
#define ADD_ADDRESS_H     50.

@interface ProductPopAddressOptionListView (private)

- (void)fadeIn;
- (void)fadeOut;

@end

@implementation ProductPopAddressOptionListView
@synthesize delegate;

#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions selectIndex:(int)selectIndex
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    if (self = [super initWithFrame:rect])
    {
        self.frame = CGRectOffset(self.frame, 0, 70);
        
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        _options = [aOptions copy];
        _selectIndex = selectIndex;
        
        _tableView = [[UITableView alloc] init];
        _tableView.frame = CGRectMake(POP_X, POP_HEARD_H + ADD_ADDRESS_H, SCREEN_WIDTH - POP_X * 2, 350);
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [self addSubview:_tableView];

        // btn news address background
        UIView *btnNewAddressBG = [[UIView alloc] initWithFrame:CGRectMake(POP_X, POP_HEARD_H, SCREEN_WIDTH - POP_X * 2, ADD_ADDRESS_H)];
        btnNewAddressBG.backgroundColor = [UIColor whiteColor];
        [self addSubview:btnNewAddressBG];
        
        // btn news address
        UIButton *btnNewAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNewAddress.titleLabel.font = [UIFont systemFontOfSize:14];
        btnNewAddress.backgroundColor = HEX_COLOR(@"0xf86052");
        
        [btnNewAddress addTarget:self action:@selector(addNewAddress:) forControlEvents:UIControlEventTouchUpInside];
        [btnNewAddress setTitle:@"添加收货地址" forState:UIControlStateNormal];
        [btnNewAddress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnNewAddress setFrame:CGRectMake(POP_X*4, POP_HEARD_H+10, SCREEN_WIDTH - POP_X * 8, ADD_ADDRESS_H-20)];
        [self addSubview:btnNewAddress];
        
        // title bg view
        int tableOriginY = _tableView.frame.origin.y - ADD_ADDRESS_H;
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(POP_X, tableOriginY - POP_HEARD_H, _tableView.frame.size.width, POP_HEARD_H)];
        splitView.backgroundColor = [UIColor colorWithHexString:@"0xf86052"];
        [self addSubview:splitView];
        
        // title text
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, _tableView.frame.size.width-40, POP_HEARD_H-5)];
        titleLabel.text = _title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [splitView addSubview:titleLabel];
        
        // Close
        UIButton *btnClosePop = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClosePop.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnClosePop addTarget:self action:@selector(closePop:) forControlEvents:UIControlEventTouchUpInside];
        [btnClosePop setTitle:@"关闭" forState:UIControlStateNormal];
        [btnClosePop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnClosePop setFrame:CGRectMake(splitView.frame.size.width-40, 5, 40, POP_HEARD_H-5)];
        [splitView addSubview:btnClosePop];
    }
    
    return self;    
}

#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];

}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyNowAddressOptionCell" owner:self options:nil] lastObject];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:110];
    
    if (row != _selectIndex) {
        iconView.image = [UIImage imageNamed:@"popUnSel.png"];
    } else {
        iconView.image = [UIImage imageNamed:@"popSeled.png"];
    }
    
    UILabel *userLabel = (UILabel *)[cell viewWithTag:111];
    userLabel.text = [[_options objectAtIndex:row] objectForKey:@"user"];
    
    UILabel *mobileLabel = (UILabel *)[cell viewWithTag:112];
    mobileLabel.text = [[_options objectAtIndex:row] objectForKey:@"mobile"];
    
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:113];
    addressLabel.text = [[_options objectAtIndex:row] objectForKey:@"address"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    _selectIndex = row;
    
    UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *iconView = (UIImageView *)[selCell viewWithTag:110];
    iconView.image = [UIImage imageNamed:@"popSeled.png"];
    
    UILabel *txtLabel = (UILabel *)[selCell viewWithTag:11];
    txtLabel.text = [[_options objectAtIndex:_selectIndex] objectForKey:@"text"];

    // tell the delegate the selection
    if (self.delegate && [self.delegate respondsToSelector:@selector(popListView:didSelectedIndex:)]) {
        [self.delegate popListView:self didSelectedIndex:_selectIndex];
    }
    
    for (int i=0; i<_options.count; i++) {
        
        if (i != row) {
            
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            UITableViewCell * otherCell = [tableView cellForRowAtIndexPath:otherIndexPath];
            UIImageView *otherAccessoryView = (UIImageView *)[otherCell viewWithTag:110];
            
            otherAccessoryView.image = [UIImage imageNamed:@"popUnSel.png"];
        }
    }
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(clearBackGroundView)]) {
        [self.delegate clearBackGroundView];
    }
    
    // dismiss self
//    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.8f];
    [self fadeOut];
}

- (void)drawRect:(CGRect)rect
{
}

- (void)closePop:(id)sender
{
    // dismiss self
//    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.8f];
    [self fadeOut];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closePop:)]) {
        [self.delegate closePop:nil];
    }
}

- (void)addNewAddress:(id)sender
{
    [self fadeOut];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addNewAddress:)]) {
        [self.delegate addNewAddress:nil];
    }
}

@end
