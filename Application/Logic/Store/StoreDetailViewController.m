//
//  StoreDetailViewController.m
//  Mall
//
//  Created by Adam on 14-12-9.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "MapViewController.h"
#import "CustomUILabel.h"

#define SCROLL_H    150

@interface StoreDetailViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    NSMutableArray *backArray;
    NSMutableArray *backLogicArray;
}

@end

@implementation StoreDetailViewController
{
    int slideCount;
    
    NSTimer *slideTime;
}

@synthesize scrollView, pageControl;
@synthesize storeId;
@synthesize mTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initiscrollViewalization
    }
    return self;
}

- (void)stopAutoSlide
{
    if (slideTime != nil) {
        
        [slideTime invalidate];
        slideTime = nil;
    }
}

#pragma mark - 退出这个页面时显示tabbar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopAutoSlide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self stopAutoSlide];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 进入视图所进入的第一个方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"商品详情";
    [self adjustView];
    
    [self loadDetailData];
}

- (void)adjustView
{
    self.mTableView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    [self.view addSubview:self.noNetWorkView];
    self.mTableView.alpha = 0;
}

#pragma mark - scrollview 委托函数  scrollview滚动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
}

#pragma mark - pagecontrol 选择器的方法
- (void)turnPage
{
    CGFloat targetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
    if (targetX >= self.scrollView.contentSize.width) {
        targetX = 0.0;
    }
    
    [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    pageControl.currentPage = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
}

#pragma mark 初始化uiview 显示商品评论
- (void)initTableFooter
{
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20,  260)];
    footview.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    UIView *footBgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 260)];
    footBgView.backgroundColor = [UIColor whiteColor];
    [footview addSubview:footBgView];
    
    UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 1)];
    [splitView setBackgroundColor:HEX_COLOR(@"0xcccccc")];
    [footview addSubview:splitView];
    
    UIButton *CommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 20, 200, 36)];
    [CommentBtn.layer setBorderWidth:1];
    CommentBtn.layer.cornerRadius=4;
    [CommentBtn.layer setMasksToBounds:YES];
    [CommentBtn setBackgroundColor:HEX_COLOR(@"0xf86052")];
    CommentBtn.layer.borderColor = [HEX_COLOR(@"0xf86052") CGColor];
    [CommentBtn setTitle:@"查看地图" forState:UIControlStateNormal];
    [CommentBtn addTarget:self action:@selector(openMap) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:CommentBtn];
    
    self.mTableView.tableFooterView = footview;
}

#pragma mark 初始化scrollview 显示轮播图片
- (void)initTableHeader:(NSArray *)imageArr
{
    
    // Clean
    [self stopAutoSlide];
    self.mTableView.tableHeaderView = nil;
    
    // Init
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_H+10)];
    headview.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
    
    // 初始化 数组 并添加图片
    slideCount = [imageArr count];
    
    // 初始化 scrollview
    CGRect scrollFrame = CGRectMake(10, 10, SCREEN_WIDTH-20, SCROLL_H);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.contentSize = CGSizeMake(0,0);//scrollview能拖动的范围
    scrollView.bounces = YES;//默认是 yes，就是滚动超过边界会反弹有反弹回来的效果。假如是 NO，那么滚动到达边界会立刻停止。
    scrollView.pagingEnabled = YES;//当值是 YES 会自动滚动到 subview 的边界。默认是NO
    scrollView.userInteractionEnabled = YES;//
    scrollView.showsHorizontalScrollIndicator = NO;//滚动时是否显示水平滚动条
    scrollView.delegate = self;
    
    [headview addSubview:scrollView];
    
    // 创建图片 imageview
    for (int i = 0; i<slideCount; i++)
    {
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@", [[imageArr objectAtIndex:i] objectForKey:@"server_name"], [[imageArr objectAtIndex:i] objectForKey:@"url"]];
        UIImageView *imageView = [[UIImageView alloc] init];
        
        [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
            // imageView.image = image;
        }];
        
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, scrollFrame.size.width, scrollFrame.size.height);
        [scrollView addSubview:imageView];
    }
    
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * slideCount, scrollFrame.size.height)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    // 初始化 pagecontrol
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 13)];
    [pageControl setCurrentPageIndicatorTintColor:HEX_COLOR(@"0xfa5e4f")];
    [pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    pageControl.numberOfPages = slideCount;
    pageControl.currentPage = 0;
    [headview addSubview:pageControl];
    
    self.mTableView.tableHeaderView = headview;
    
    if (slideCount > 1) {

        slideTime = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(turnPage) userInfo:nil repeats:YES];
    }
}

#pragma mark - UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    int row = indexPath.row;
    
    switch (row) {
            
        case 0:
        {
            if (backLogicArray != nil) {

                CGRect productRect = [CommonUtils sizeWithText:[backLogicArray valueForKey:@"store_name_cn"]
                                                     withFont:[UIFont systemFontOfSize:15.f]
                                                         size:CGSizeMake(264, MAXFLOAT)];
                
                return productRect.size.height + 29;
            } else {

                return 70;
            }
        }
            break;
            
        case 1:
        {
            return 70;
        }
            break;
            
        case 2:
        {
            if (backLogicArray != nil) {
                
                CGRect productRect = [CommonUtils sizeWithText:[backLogicArray valueForKey:@"store_address"]
                                                      withFont:[UIFont systemFontOfSize:15.f]
                                                          size:CGSizeMake(264, MAXFLOAT)];
                
                return productRect.size.height + 60;
            } else {
                
                return 70;
            }
        }
            break;

        default:
            break;
    }
    
    return 0;
}

#pragma mark 返回tableview的行数

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark 点击cell行触发事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark 初始化商品详情的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int row = indexPath.row;
    
    switch (row) {
        case 0:
        {
            
            if (row == 0) {
                
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                UIView *bgView = [[UIView alloc] init];
                bgView.backgroundColor = [UIColor whiteColor];
                [cell.contentView addSubview:bgView];
                
                UILabel *productDesc = [[UILabel alloc] init];
                productDesc.textColor = HEX_COLOR(@"0x616161");
                productDesc.font = [UIFont systemFontOfSize:15.f];
                productDesc.numberOfLines = 0;
                productDesc.text = [backLogicArray valueForKey:@"store_name_cn"];
                
                CGRect productRect =[CommonUtils sizeWithText:productDesc.text
                                                     withFont:[UIFont systemFontOfSize:15.f]
                                                         size:CGSizeMake(SCREEN_WIDTH-22, MAXFLOAT)];
                
                productDesc.frame = CGRectMake(28, 13, 264, productRect.size.height);
                
                [cell.contentView addSubview:productDesc];
                [productDesc sizeToFit];
                
                bgView.frame = CGRectMake(10, 0, SCREEN_WIDTH-20, productRect.size.height + 29);
                cell.contentView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
                cell.contentView.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, productRect.size.height + 29);
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        }
            break;
            
        case 1:
        {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"StoreContractCell" owner:self options:nil] lastObject];
            
            UILabel *title = (UILabel*)[cell.contentView viewWithTag:10];
            UILabel *desc = (UILabel*)[cell.contentView viewWithTag:11];
            
            title.text = @"联系电话";
            desc.text = [backLogicArray valueForKey:@"mobilephone"];
            
            UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 1)];
            splitView.backgroundColor = HEX_COLOR(@"0xcccccc");
            [cell.contentView addSubview:splitView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        case 2:
        {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"StoreContractCell" owner:self options:nil] lastObject];
            
            UIView *cellBgView = (UIView*)[cell.contentView viewWithTag:9];
            UILabel *title = (UILabel*)[cell.contentView viewWithTag:10];
            CustomUILabel *desc = (CustomUILabel*)[cell.contentView viewWithTag:11];
            
            title.text = @"联系地址";
            desc.text = [backLogicArray valueForKey:@"store_address"];
            
            CGRect productRect = [CommonUtils sizeWithText:desc.text
                                           withFont:[UIFont systemFontOfSize:15.f]
                                               size:CGSizeMake(desc.frame.size.width, MAXFLOAT)];
            desc.frame = CGRectMake(desc.frame.origin.x, desc.frame.origin.y, desc.frame.size.width, productRect.size.height);
            [desc setVerticalAlignment:VerticalAlignmentTop];
            
            cellBgView.frame = CGRectMake(cellBgView.frame.origin.x, cellBgView.frame.origin.y, cellBgView.frame.size.width, productRect.size.height + 60);
            
            UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 1)];
            splitView.backgroundColor = HEX_COLOR(@"0xcccccc");
            [cell.contentView addSubview:splitView];

//            [cell.contentView setBackgroundColor:[UIColor blueColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - 显示商品的内容
- (void) loadDetailData
{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:storeId forKey:@"store_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_other_getStoreDetail"
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
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if (backArray && [backArray count] > 0) {

                                         [backArray removeAllObjects];
                                     }
                                     
                                     if (backLogicArray && [backLogicArray count] > 0) {
                                         
                                         [backLogicArray removeAllObjects];
                                     }
                                     
                                     backArray = [backDic valueForKey:@"data"];
                                     backLogicArray = [backArray valueForKey:@"store"];
                                     
                                     NSArray *imageArr = [backLogicArray valueForKey:@"imagelist"];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         
                                         [self initTableHeader:imageArr];
                                         [self initTableFooter];
                                     });
                                     
                                     [self.mTableView reloadData];
                                     
                                     if (self.noNetWorkView.superview) {
                                         [self.noNetWorkView removeFromSuperview];
                                         self.mTableView.alpha = 1;
                                     }
                                 }
                             }];
     }];
}

- (void)openMap
{

    NSString *longitudeStr = [backLogicArray valueForKey:@"longitude"];
    NSString *latitudeStr = [backLogicArray valueForKey:@"latitude"];
    NSString *titleStr = [backLogicArray valueForKey:@"store_name_cn"];
    NSString *storeAddressStr = [backLogicArray valueForKey:@"store_address"];
    
    MapViewController *mapVC = [[MapViewController alloc] initWithLatitude:[latitudeStr doubleValue]
                                                                 longitude:[longitudeStr doubleValue]
                                                                     title:titleStr
                                                                  subTitle:storeAddressStr];
    
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"门店详情" style:0 target:nil action:nil];
    [self.navigationController pushViewController:mapVC animated:YES];
}

@end
