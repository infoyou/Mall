//
//  ProductCommentsViewController.m
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ProductCommentsViewController.h"

#define COMMENTSX 36.3f
#define COMMENTSH 28
#define CommentNumber 100

@interface ProductCommentsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *backCommentsArr;
    UIView *backView;//蒙板view
    UIView *comments;//提交评论view
    
    UITextView *goodsContentsText;//评论textview
    int goodsCommentsImgNumber;
}

@end

@implementation ProductCommentsViewController
@synthesize productId;
@synthesize btnComment;
@synthesize btnCommentBG;
@synthesize productCommentsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.visibleViewController.navigationItem.title = @"商品评论";
    
    [self adjustView];
    
    [self loadCommentData];
}

- (void)adjustView
{
    int tableH = SCREEN_HEIGHT-50-64;
    productCommentsTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, tableH);
    btnCommentBG.frame = CGRectMake(0, tableH, SCREEN_WIDTH, 50);
    
    btnComment.layer.cornerRadius = 4;
    [btnComment.layer setMasksToBounds:YES];
}

#pragma mark 点击提交按钮
- (void)submitComments
{
    NSLog(@"%@",goodsContentsText.text);
    if (nil == goodsContentsText.text || [goodsContentsText.text isEqualToString:@""] || goodsCommentsImgNumber == 0) {
        [self showTimeAlert:@"提示:" message:@"您忘记评论或评分了!"];
    } else {
        [self createCommentData];
    }
}

#pragma mark 键盘退出
- (void)dismissKeyBoard
{
    [goodsContentsText resignFirstResponder];
}

#pragma mark 点击蒙板返回评论页面
- (void)dismissView
{
    [comments removeFromSuperview];
    [backView removeFromSuperview];
}

- (void)goodsScoreChange:(UIButton *)btn
{
    
    if ([btn isTouchInside]) {
        
        if ([btn isSelected]) {
            for (int i=btn.tag; i<CommentNumber+5; i++) {
                UIButton *btnNumber = (UIButton*)[comments viewWithTag:i];
                [btnNumber setBackgroundImage:[UIImage imageNamed:@"icon83.png"] forState:UIControlStateNormal];
                btnNumber.selected = NO;
                goodsCommentsImgNumber = btn.tag - CommentNumber;
            }
        } else {
            for (int i=CommentNumber; i<=btn.tag; i++) {
                UIButton *btnNumber = (UIButton*)[comments viewWithTag:i];
                [btnNumber setBackgroundImage:[UIImage imageNamed:@"icon84.png"] forState:UIControlStateNormal];
                btnNumber.selected = YES;
                goodsCommentsImgNumber = btn.tag + 1 - CommentNumber;
            }
        }
    }
    
    DLog(@"goodsCommentsImgNumber = %d", goodsCommentsImgNumber);
}

#pragma mark 点击我要评论弹出评论蒙板
- (IBAction)CommentsBtn:(id)sender {
    
    NSLog(@"我要评论");
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  SCREEN_HEIGHT)];
    backView.backgroundColor = [UIColor grayColor];
    backView.alpha = 0.5;
    comments = [[UIView alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH,  260)];
    comments.backgroundColor = [UIColor whiteColor];
    
    UILabel *productScore = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
    productScore.text = @"商品评分";
    productScore.textColor = HEX_COLOR(@"0x333333");
    
    for (int i=0; i<5; i++) {
        
        UIButton *btnImg = [[UIButton alloc] initWithFrame:CGRectMake(productScore.frame.origin.x + (COMMENTSX + 1) *i, productScore.frame.origin.y +25, COMMENTSX, COMMENTSH)];
        [btnImg setBackgroundImage:[UIImage imageNamed:@"icon83.png"] forState:UIControlStateNormal];
        btnImg.tag = i+CommentNumber;
        [btnImg addTarget:self action:@selector(goodsScoreChange:) forControlEvents:UIControlEventTouchUpInside];
        [comments addSubview:btnImg];
    }
    
    goodsCommentsImgNumber = 0;
    UILabel *productContents = [[UILabel alloc] initWithFrame:CGRectMake(productScore.frame.origin.x, productScore.frame.origin.y + 60, productScore.frame.size.width + 25, productScore.frame.size.height)];
    productContents.text = @"输入评论内容";
    productContents.textColor = HEX_COLOR(@"0x333333");
    
    /// 调用dismissKeyBoard方法消失键盘
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    goodsContentsText = [[UITextView alloc] initWithFrame:CGRectMake(productContents.frame.origin.x, productContents.frame.origin.y + 25, 300, 80)];
    goodsContentsText.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    goodsContentsText.layer.borderWidth = 0.5f;
    goodsContentsText.layer.borderColor = HEX_COLOR(@"0xaeaeae").CGColor;
    
    UIButton *submitContents = [[UIButton alloc] initWithFrame:CGRectMake(122,205, 80, 30)];
    //submitContents.backgroundColor = [UIColor redColor];
    [submitContents.layer setBorderWidth:1];
    submitContents.layer.cornerRadius=8;
    [submitContents.layer setMasksToBounds:YES];
    [submitContents setBackgroundColor:[UIColor redColor]];
    submitContents.layer.borderColor = [[UIColor redColor] CGColor];
    [submitContents setTitle:@"提交" forState:UIControlStateNormal];
    [submitContents addTarget:self action:@selector(submitComments) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tapGestureview = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
    [comments addGestureRecognizer:tapGesture];
    
    [comments addSubview:productScore];
    [comments addSubview:productContents];
    [comments addSubview:goodsContentsText];
    [backView addGestureRecognizer:tapGestureview];
    [comments addSubview:submitContents];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:comments];
}

#pragma mark - 显示商品评论
- (void) loadCommentData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"100" forKey:@"num"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_getcommentlist"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString* requestStr) {
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         // [self.navigationController popViewControllerAnimated:YES];
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backDic != nil) {
                                         
                                         int total = [[[backDic valueForKey:@"data"] objectForKey:@"total"] intValue];
                                         
                                         if (total > 0) {

                                             backCommentsArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                             NSLog(@"%d",backCommentsArr.count);
                                             [self.productCommentsTable reloadData];
                                         } else {
                                             
//                                             [self.navigationController popViewControllerAnimated:YES];
                                             
                                             [self showHUDWithText:@"暂无内容"];
                                         }
                                     }
                                 }
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
     }];
    
}

- (void) createCommentData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    [dataDict setObject:@(goodsCommentsImgNumber) forKey:@"score"];
    [dataDict setObject:goodsContentsText.text forKey:@"content"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_comment"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString*requestStr) {
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         // [self.navigationController popViewControllerAnimated:YES];
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backDic != nil) {
                                         
                                         if ([backDic valueForKey:@"data"]!=NULL) {
                                             [self loadCommentData];
                                             [self dismissView];
                                         } else {
                                             NSLog(@"评论失败");
                                         }
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark tableview每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentH = [self getContentHeight:indexPath];
    
    if (contentH + 50 > 100) {
        return contentH + 50;
    }
    
    return 100;
}

#pragma mark 返回tableview的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return backCommentsArr.count;
}

#pragma mark - tableview的cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductCommentsCell" owner:self options:nil] lastObject];
    
    CGFloat contentH = [self getContentHeight:indexPath];
    
    UILabel *content = (UILabel *)[cell viewWithTag:11];
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:12];
    UILabel *name = (UILabel *)[cell viewWithTag:13];
    UILabel *time = (UILabel *)[cell viewWithTag:14];
    
    if (contentH > 40) {
        
        content.frame = CGRectMake(content.frame.origin.x, content.frame.origin.y, 270, contentH);
        iconView.frame = CGRectOffset(iconView.frame, 0, contentH-40);
        name.frame = CGRectOffset(name.frame, 0, contentH-40);
        time.frame = CGRectOffset(time.frame, 0, contentH-40);
    }
    
    NSString *nameStr = [[backCommentsArr[indexPath.row] valueForKey:@"creator"] valueForKey:@"nick_name"];
    if (![nameStr isEqualToString:@""]) {
        name.text = nameStr;
    } else {
        name.text = @"游客";
    }
    
    content.text = [backCommentsArr[indexPath.row] valueForKey:@"content"];
    time.text = [backCommentsArr[indexPath.row] valueForKey:@"comment_date"];
    NSString *imageUrl = [[backCommentsArr[indexPath.row] valueForKey:@"creator"] valueForKey:@"thumbnail_url"];
    
    if (imageUrl && imageUrl.length > 0) {
        
        [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
        }];
    } else {
        
        iconView.image = [UIImage imageNamed:@"icon.png"];
    }
    
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = iconView.bounds.size.width/2;
    
    if (indexPath != 0) {
        
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        [splitView setBackgroundColor:HEX_COLOR(@"0xd3d3d3")];
        [cell.contentView addSubview:splitView];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)getContentHeight:(NSIndexPath *)indexPath
{
    return [CommonUtils sizeWithText:[backCommentsArr[indexPath.row] valueForKey:@"content"] withFont:[UIFont systemFontOfSize:15] size:CGSizeMake(270, CGFLOAT_MAX)].size.height;
}

@end
