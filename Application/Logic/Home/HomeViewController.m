//
//  HomeViewController.m
//  Mall
//
//  Created by Adam on 14-12-3.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "HomeViewController.h"
#import "ProductDetailViewController.h"
#import "BarCodeViewController.h"

#import "GrouponListViewController.h"
#import "StoreListViewController.h"

#define SCROLL_H       120
#define SEARCH_BAR_W   178


// ADDetailObject
@interface ADDetailObject : NSObject
{}

@property (nonatomic, retain) NSString* image_url;
@property (nonatomic, retain) NSString* image_link;
@property (nonatomic, retain) NSString* image_title;
@property (nonatomic, retain) NSString* sort;
@property (nonatomic, retain) NSString* price;
@property (nonatomic, retain) NSString* product_id;

@end

@implementation ADDetailObject

@synthesize image_url = _image_url;
@synthesize image_link = _image_link;
@synthesize image_title = _image_title;
@synthesize sort = _sort;
@synthesize price = _price;
@synthesize product_id = _product_id;

@end

// ADCellObject
@interface ADCellObject : NSObject
{}

// module_type 为0 首页广告焦点图 1 一方格图 2 二方格图 3 三方格 4 四方格 5 商品图
@property (nonatomic, retain) NSString* module_type;
@property (nonatomic, retain) NSString* module_des;
@property (nonatomic, retain) NSString* module_title;
@property (nonatomic, retain)NSMutableArray* module_data;

@end

@implementation ADCellObject

@synthesize module_type = _module_type;
@synthesize module_des = _module_des;
@synthesize module_title = _module_title;
@synthesize module_data = _module_data;

@end


@interface HomeViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EGORefreshTableDelegate>
{
    UISearchBar *mSearchBar;
    UIButton *mSearchCancelBtn;
}

@property (nonatomic, strong) NSMutableArray *allData;

@property (nonatomic, strong) UISearchBar *mSearchBar;
@property (nonatomic, strong) UIButton *mSearchCancelBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIScrollView *promotionScrollView;
@property (nonatomic, strong) UIPageControl *promotionPageControl;
@property (nonatomic, strong) UIImageView *promotionLeftImg;
@property (nonatomic, strong) UIImageView *promotionRightImg;

@end

@implementation HomeViewController
{
    int slideCount;
    
    NSTimer *slideTime;
}

@synthesize mSearchBar;
@synthesize mSearchCancelBtn;
@synthesize scrollView;
@synthesize pageControl;
@synthesize mTableView;
@synthesize allData;

@synthesize promotionScrollView;
@synthesize promotionPageControl;
@synthesize promotionLeftImg;
@synthesize promotionRightImg;

- (id)init
{
    self = [super init];
    
    if (self) {
        // Custom initialization
        [self initData];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    allData = [NSMutableArray array];
}

- (void)startAutoSlide
{
    slideTime = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(turnPage) userInfo:nil repeats:YES];
}

- (void)stopAutoSlide
{
    if (slideTime != nil) {
        
        [slideTime invalidate];
        slideTime = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showOrHideTabBar:NO];
    
    if (slideTime != nil) {
        [self stopAutoSlide];
        [self startAutoSlide];
    } else {
        [self startAutoSlide];
    }
    
//    [self loadContentData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopAutoSlide];
}

- (void)initNaviBarView
{
    // navi
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];

    // logo
    UIButton *btnLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogo setImage:[UIImage imageNamed:@"logo_home.png"] forState:UIControlStateNormal];
    [btnLogo setFrame:CGRectMake(5, 8, 60, 26)];
    
    //搜索
    mSearchBar = [[UISearchBar alloc] init];
    ///设置搜索框的默认提示
    mSearchBar.placeholder = @"请输入关键字";
    
    [mSearchBar setFrame:CGRectMake(75, 5, SEARCH_BAR_W, 33)];
    [mSearchBar setBarTintColor:HEX_COLOR(NAVI_BAR_BG_COLOR)];
    [mSearchBar setBackgroundColor:HEX_COLOR(NAVI_BAR_BG_COLOR)];
    [mSearchBar setTintColor:HEX_COLOR(@"0x333333")];
    [mSearchBar.layer setBorderWidth:1.0f];
    [mSearchBar.layer setBorderColor:HEX_COLOR(NAVI_BAR_BG_COLOR).CGColor];
    [mSearchBar.layer setMasksToBounds:YES];
    mSearchBar.delegate = self;
    
    mSearchCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mSearchCancelBtn.frame = CGRectMake(SEARCH_BAR_W+25, 0, 50, 44);
    [mSearchCancelBtn setTintColor:HEX_COLOR(NAVI_BAR_BG_COLOR)];
    [mSearchCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [mSearchCancelBtn addTarget:self action:@selector(doSearchBarCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    mSearchCancelBtn.hidden = YES;
    
    //扫一扫
    UIImageView *sweepImg = [[UIImageView alloc] initWithFrame:CGRectMake(275, 10, 20, 20.5)];
    sweepImg.image = [UIImage imageNamed:@"barcode.png"];
    [naviView addSubview:sweepImg];
    
    UIButton *btnSweep = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSweep addTarget:self action:@selector(barCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnSweep setFrame:CGRectMake(265, 0, 55, 44)];
    
    [naviView addSubview:btnLogo];
    [naviView addSubview:mSearchBar];
    [naviView addSubview:mSearchCancelBtn];
    [naviView addSubview:btnSweep];
    
    self.navigationItem.titleView = naviView;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNaviBarView];
    
    [self loadContentData];
    
}

- (void)adjustView
{
    mTableView.alpha = 0;
    
    [self.view addSubview:self.noNetWorkView];
    
    if (SCREEN_HEIGHT < 568) {
        
        mTableView.frame = CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y, mTableView.frame.size.width, mTableView.frame.size.height - (64+35));
    }
}

#pragma mark - UIScrollViewDelegate method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (sender == promotionScrollView) {
        
        CGFloat pagewidth = self.promotionScrollView.frame.size.width;
        int slideTotalCount = self.promotionScrollView.contentSize.width/pagewidth;
        int page = floor((self.promotionScrollView.contentOffset.x - pagewidth/slideTotalCount)/pagewidth)+1;
        promotionPageControl.currentPage = page;
        
        if (page > 0) {
            promotionLeftImg.image = [UIImage imageNamed:@"scrollLeft_sel.png"];
            if (page != slideTotalCount-1) {
                promotionRightImg.image = [UIImage imageNamed:@"scrollRight_sel.png"];
            } else {
                promotionRightImg.image = [UIImage imageNamed:@"scrollRight.png"];
            }
        } else {
            promotionLeftImg.image = [UIImage imageNamed:@"scrollLeft.png"];
            if (slideTotalCount > 0) {
                promotionRightImg.image = [UIImage imageNamed:@"scrollRight_sel.png"];
            }
        }
    } else {
        
        pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.mTableView];
    }
    
}

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:2.0];
    } else if(aRefreshPos == EGORefreshFooter) {
        
//        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
}

- (void)refreshView
{
    [self loadContentData];
}

#pragma mark - EGORefreshTableDelegate methods
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate *)egoRefreshTableDataSourceLastUpdated:(UIView *)view
{
    return [NSDate date];
}

// pagecontrol 选择器的方法
- (void)turnPage
{
    CGFloat targetX = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
    if (targetX >= self.scrollView.contentSize.width) {
        targetX = 0.0;
    }
    
    [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    pageControl.currentPage = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
}

- (void)initTableHeader
{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_H)];
    
    // 初始化 scrollview
    CGRect scrollFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_H);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.bounces = YES;//默认是 yes，就是滚动超过边界会反弹有反弹回来的效果。假如是 NO，那么滚动到达边界会立刻停止。
    scrollView.pagingEnabled = YES;//当值是 YES 会自动滚动到 subview 的边界。默认是NO
    scrollView.delegate = self;//代理
    scrollView.userInteractionEnabled = YES;//
    scrollView.showsHorizontalScrollIndicator = NO;//滚动时是否显示水平滚动条
    scrollView.showsVerticalScrollIndicator = NO;
    [headview addSubview:scrollView];
    
    // imageview
    ADCellObject *adCellObject = (ADCellObject *)[allData objectAtIndex:0];
    slideCount = [adCellObject.module_data count];
    
    for (int i = 0; i<slideCount; i++)
    {
        ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        [self addTapGestureRecognizer:imageView];
        
        [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
//            imageView.image = image;
        }];
        
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, scrollFrame.size.width, scrollFrame.size.height);
        [scrollView addSubview:imageView];
        imageView = nil;
    }
    
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * slideCount, scrollFrame.size.height)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    // Page Control
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 105, SCREEN_WIDTH, 13)];
    [pageControl setCurrentPageIndicatorTintColor:HEX_COLOR(@"0xf86052")];
    [pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    pageControl.numberOfPages = slideCount;
    pageControl.currentPage = 0;
    [headview addSubview:pageControl];
    
    self.mTableView.tableHeaderView = headview;
    
    slideTime = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(turnPage) userInfo:nil repeats:YES];

}

#pragma mark - UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellHeight = 0;
    
    int rowNumber = indexPath.row;
    
    if (rowNumber == 0) {
        cellHeight = 79;
    } else if (rowNumber >= [allData count]) {
        cellHeight = 88;
    } else {
        int moduleType = [((ADCellObject *)[allData objectAtIndex:rowNumber]).module_type intValue];
        
        switch (moduleType) {
            case 1:
            {
                cellHeight = 120;
            }
                break;
                
            case 2:
            case 3:
            case 4:
            {
                cellHeight = 143;
            }
                break;
                
            case 5:
            {
                cellHeight = 168;
            }
                break;
                
            default:
                break;
        }
    }
    
    if (cellHeight != 0 && rowNumber != 0) {
        cellHeight += 6;
    }
    
    return cellHeight;
}

/// 返回mTableView的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allData count]+1;
}

/// 绑定cell的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"HomeMallCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //    if (cell != nil) {
    //
    //        for (UIView *subView in cell.contentView.subviews)
    //        {
    //            [subView removeFromSuperview];
    //        }
    //    }
    
    int rowNumber = indexPath.row;
    
    if (nil == cell) {
        
        if (rowNumber == 0) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TopCell" owner:self options:nil] lastObject];
            
            for (int i=101; i<=104; i++) {
                
                UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:i];
                [self addTapGestureRecognizer:imgView];
            }
            
        } else if (rowNumber >= [allData count]) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BottomCell" owner:self options:nil] lastObject];
            
            for (int i=201; i<=203; i++) {
                
                UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:i];
                [self addTapGestureRecognizer:imgView];
            }
            
        } else {
            
            ADCellObject *adCellObject = (ADCellObject *)[allData objectAtIndex:rowNumber];
            int moduleType = [adCellObject.module_type intValue];
            
            switch (moduleType) {
                    
                case 1:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"OneCell" owner:self options:nil] lastObject];
                    
                    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:10];
                    imgView.tag = rowNumber*1000;
                    [self addTapGestureRecognizer:imgView];
                    
                    ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:0];
                    
                    [imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        //Nothing.
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        //Nothing.
//                        imgView.image = image;
                    }];
                    
                }
                    break;
                    
                case 2:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"TwoCell" owner:self options:nil] lastObject];
                    
                    for (int i=0; i<moduleType; i++) {
                        
                        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:(10+i)];
                        imgView.tag = rowNumber*1000 + i;
                        [self addTapGestureRecognizer:imgView];
                        
                        ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:i];
                        
                        [imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            //Nothing.
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            //Nothing.
//                            imgView.image = image;
                        }];
                    }
                    
                }
                    break;
                    
                case 3:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"ThreeCell" owner:self options:nil] lastObject];
                    
                    for (int i=0; i<moduleType; i++) {
                        
                        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:(10+i)];
                        imgView.tag = rowNumber*1000 + i;
                        [self addTapGestureRecognizer:imgView];
                        
                        
                        ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:i];
                        
                        [imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            //Nothing.
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            //Nothing.
//                            imgView.image = image;
                        }];
                    }
                    
                }
                    break;
                    
                case 4:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"FourCell" owner:self options:nil] lastObject];
                    
                    for (int i=0; i<moduleType; i++) {
                        
                        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:(10+i)];
                        imgView.tag = rowNumber*1000 + i;
                        [self addTapGestureRecognizer:imgView];
                        
                        ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:i];
                        
                        [imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            //Nothing.
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            //Nothing.
//                            imgView.image = image;
                        }];
                    }
                    
                }
                    break;
                    
                case 5:
                {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionCell" owner:self options:nil] lastObject];
                    
                    int imgCount = [adCellObject.module_data count];
                    int imgNumInOneScroll = 3;
                    int pageNum = imgCount/imgNumInOneScroll;
                    if (imgCount%imgNumInOneScroll != 0) {
                        pageNum++;
                    }
                    
                    //*
                    promotionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 34, 270, 113)];
                    //默认是 yes，就是滚动超过边界会反弹有反弹回来的效果。假如是 NO，那么滚动到达边界会立刻停止。
                    promotionScrollView.bounces = YES;
                    //当值是 YES 会自动滚动到 subview 的边界。默认是NO
                    promotionScrollView.pagingEnabled = YES;
                    promotionScrollView.delegate = self;//代理
                    promotionScrollView.userInteractionEnabled = YES;//
                    //滚动时是否显示水平滚动条
                    promotionScrollView.showsHorizontalScrollIndicator = NO;
                    promotionScrollView.showsVerticalScrollIndicator = NO;
                    
                    for (int pageIndex = 0; pageIndex < pageNum; pageIndex ++)
                    {
                        
                        UIView *scrollUnitView = [[UIView alloc] initWithFrame:CGRectMake((270 * pageIndex), 0, 270, 113)];
                        
                        int offsetVal = pageIndex*imgNumInOneScroll;
                        int totalCount = offsetVal + imgNumInOneScroll;
                        
                        if (totalCount > imgCount) {
                            totalCount = imgCount;
                        }
                        
                        for (int i=offsetVal; i<totalCount; i++) {
                            
                            int oneW = 85;
                            UIImageView *imgView = [[UIImageView alloc] init];
                            imgView.tag = rowNumber*1000 + i;
                            [self addTapGestureRecognizer:imgView];
                            
                            int currentX = i%imgNumInOneScroll;
                            
                            imgView.frame = CGRectMake(currentX*oneW+currentX*7, 0, oneW, 112);
                            ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:i];
                            
                            [imgView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:adDetailObject.image_url] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                //Nothing.
                            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                //Nothing.
//                                imgView.image = image;
                            }];
                            
                            // Bottom
                            UIView *bottomBG = [[UIView alloc] initWithFrame:CGRectMake(0, 78, oneW, 35)];
                            bottomBG.backgroundColor = [UIColor whiteColor];
                            bottomBG.alpha = 0.8;
                            
                            // Name
                            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, oneW, 20)];
                            nameLabel.text = adDetailObject.image_title;
                            nameLabel.font = [UIFont systemFontOfSize:11];
                            nameLabel.textColor = HEX_COLOR(@"0x333333");
                            nameLabel.textAlignment = NSTextAlignmentCenter;
                            [bottomBG addSubview:nameLabel];
                            
                            // Price
                            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, oneW, 20)];
                            priceLabel.text = [NSString stringWithFormat:@"￥%@", adDetailObject.price];
                            priceLabel.font = [UIFont systemFontOfSize:12];
                            priceLabel.textColor = HEX_COLOR(@"0xf86052");
                            priceLabel.textAlignment = NSTextAlignmentCenter;
                            [bottomBG addSubview:priceLabel];
                            
                            [imgView addSubview:bottomBG];
                            
                            [scrollUnitView addSubview:imgView];
                        }
                        
                        [promotionScrollView addSubview:scrollUnitView];
                    }
                    
                    [promotionScrollView setContentSize:CGSizeMake(270 * pageNum, 113)];
                    [cell.contentView addSubview:promotionScrollView];
                    
                    // UI Page Control
                    promotionPageControl = (UIPageControl *)[cell.contentView viewWithTag:102];
                    promotionPageControl.numberOfPages = pageNum;
                    promotionPageControl.currentPage = 0;
                    
                    promotionLeftImg = (UIImageView *)[cell.contentView viewWithTag:110];
                    promotionRightImg = (UIImageView *)[cell.contentView viewWithTag:111];
                    
                    if (pageNum > 0) {
                        promotionRightImg.image = [UIImage imageNamed:@"scrollRight_sel.png"];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    
    if (indexPath.row != 0) {
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-6, SCREEN_WIDTH, 6.f)];
        splitView.backgroundColor = HEX_COLOR(VIEW_BG_COLOR);
        [cell.contentView addSubview:splitView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return  cell;
}

#pragma mark - 首页广告配置列表
- (void) loadContentData
{
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_adv_getindexcontent"
                                                      dataDict:nil];
    
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
//                                         [self.navigationController popViewControllerAnimated:YES];
                                         [self performSelector:@selector(finishedLoadData) withObject:nil afterDelay:0];
                                     }];
                                     
                                     /*
                                     [hud setCaption:@"联网失败"];
                                     [hud setActivity:NO];
                                     [hud update];
                                     
                                     [self performBlock:^{
                                         [hud hideWithCompletion:^{
                                             
//                                             sender.enabled = YES;
//                                             [self dismissViewControllerAnimated:YES completion:^{
//                                                 if (self.dismissCompletion) {
//                                                     self.dismissCompletion();
//                                                 }
//                                             }];
                                         }];
                                     } afterDelay:.5f];
                                     */
                                     
                                 } else {
                                     
                                     if (allData && [allData count] > 0) {
                                         [allData removeAllObjects];
                                     }
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     NSDictionary* dataDic = OBJ_FROM_DIC(backDic, @"data");
                                     NSArray *list = OBJ_FROM_DIC(dataDic, @"app_content");
                                     
                                     int showIndex = 0;
                                     
                                     for (NSDictionary *totalDic in list) {
                                         
                                         ADCellObject *adCellObject = [[ADCellObject alloc] init];
                                         
                                         adCellObject.module_type = STRING_VALUE_FROM_DIC(totalDic, @"module_type");
                                         adCellObject.module_des = STRING_VALUE_FROM_DIC(totalDic, @"module_des");
                                         adCellObject.module_title = STRING_VALUE_FROM_DIC(totalDic, @"module_title");
                                         adCellObject.module_data = [NSMutableArray array];
                                         
                                         NSArray *itemList = OBJ_FROM_DIC(totalDic, @"module_data");
                                         
                                         
                                         int detailIndex = 0;
                                         for (NSDictionary *itemDic in itemList) {
                                             
                                             ADDetailObject *adDetailObject = [[ADDetailObject alloc] init];
                                             adDetailObject.image_url = STRING_VALUE_FROM_DIC(itemDic, @"image_url");
                                             adDetailObject.image_link = STRING_VALUE_FROM_DIC(itemDic, @"image_link");
                                             adDetailObject.image_title = STRING_VALUE_FROM_DIC(itemDic, @"image_title");
                                             adDetailObject.sort = STRING_VALUE_FROM_DIC(itemDic, @"sort");
                                             adDetailObject.price = STRING_VALUE_FROM_DIC(itemDic, @"price");
                                             adDetailObject.product_id = STRING_VALUE_FROM_DIC(itemDic, @"product_id");
                                             
                                             [adCellObject.module_data insertObject:adDetailObject atIndex:detailIndex++];
                                         }
                                         
                                         [allData insertObject:adCellObject atIndex:showIndex++];
                                     }
                                     
                                     DLog(@"allData = %@", allData);
                                     
                                     if ([allData count] > 0)
                                     {
                                         [self.mTableView reloadData];
                                         
                                         self.mTableView.showsVerticalScrollIndicator = NO;
                                         [self initTableHeader];
                                         
                                         [self createHeaderView];
                                         
                                         if (self.noNetWorkView.superview) {
                                             [self.noNetWorkView removeFromSuperview];
                                             mTableView.alpha = 1;
                                         }
                                     }
                                     
                                     [self performSelector:@selector(finishedLoadData) withObject:nil afterDelay:0];
                                 }
                             }];
     }];
    
}

#pragma mark - handle action
- (void) barCodeClicked:(id)sender
{
    DLog(@"btn Sweep Clicked");
    
    BarCodeViewController *barCodeVC = [[BarCodeViewController alloc] init];
    
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:0 target:nil action:nil];
    [self.navigationController pushViewController:barCodeVC animated:YES];
}

#pragma mark - image touch event
- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    if (viewTag >= 101 && viewTag <= 104) {
        DLog(@"Top Action");
        
        switch (viewTag) {
            case 101:
            {
                // 特价活动
                [self showHUDWithText:@"特价活动..."];
            }
                break;
                
            case 102:
            {
                // 团购商品
                GrouponListViewController *grouponVC = [[GrouponListViewController alloc] init];
                self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:0 target:nil action:nil];
                
                [self.navigationController pushViewController:grouponVC animated:YES];
            }
                break;
                
            case 103:
            {
                // 商品分类
                [self showHUDWithText:@"商品分类..."];
            }
                break;
                
            case 104:
            {
                // 门店列表
                StoreListViewController *grouponVC = [[StoreListViewController alloc] init];
                self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:0 target:nil action:nil];
                
                [self.navigationController pushViewController:grouponVC animated:YES];
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
    if (viewTag >= 201 && viewTag <= 203) {
        DLog(@"Bottom Action");
        
        switch (viewTag) {
            case 201:
            {
                // 咨询中心
                [self showHUDWithText:@"咨询中心..."];
            }
                break;
                
            case 202:
            {
                // 关于我们
                [self showHUDWithText:@"关于我们..."];
            }
                break;
                
            case 203:
            {
                // 帮助中心
                [self showHUDWithText:@"帮助中心..."];
            }
                break;
                
            default:
                break;
        }

        return;
    }
    
    int showIndex = viewTag/1000;
    int showRow = viewTag%1000;
    
    ADCellObject *adCellObject = (ADCellObject *)[allData objectAtIndex:showIndex];
    ADDetailObject *adDetailObject = (ADDetailObject *)[adCellObject.module_data objectAtIndex:showRow];
    
    if ([adCellObject.module_type isEqualToString:@"5"]) {
        // 商品展示
        
        ProductDetailViewController *productVC = [[ProductDetailViewController alloc] init];
        productVC.productId = adDetailObject.product_id;
        self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:0 target:nil action:nil];
        [self.navigationController pushViewController:productVC animated:YES];
        
    } else {
        
        NSString *actionStr = adDetailObject.image_link;
        
        // 商品列表
        if ([actionStr hasPrefix:@"5adian://shop/list"]) {
        }
        
        // 商品详情
        if ([actionStr hasPrefix:@"5adian://shop/detail"]) {
            NSArray *actionArray = [actionStr componentsSeparatedByString:@"/"];
            
            // NSString *customId = [actionArray objectAtIndex:4];
            NSString *detailId = [actionArray objectAtIndex:5];
            
            ProductDetailViewController *productVC = [[ProductDetailViewController alloc] init];
            productVC.productId = detailId;
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:0 target:nil action:nil];
            [self.navigationController pushViewController:productVC animated:YES];
        }
        
        // 活动列表
        if ([actionStr hasPrefix:@"5adian://event/list"]) {
            
        }
        
        // 活动详情
        if ([actionStr hasPrefix:@"5adian://event/detail"]) {
            
        }
    }
}

// 初始化刷新视图
- (void) createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0, 0.0f - self.view.bounds.size.height,
                                     SCREEN_WIDTH, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
    [mTableView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void) finishedLoadData
{
    [self finishReloadingData];
}

- (void) finishReloadingData
{
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mTableView];
    }
    
}

- (void)btnNoNetWorkClicked:(id)sender
{
    [self loadContentData];
//    [_refreshHeaderView headerBeginRefreshing];
}

#pragma mark - UIScrollViewDelegate method
//滑动mTableView退出键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [mSearchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate method

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBar Search Button Clicked");
    [mSearchBar resignFirstResponder];
    
    // 切换到产品列表
    [AppManager instance].productKeyWord = searchBar.text;
    [((ProductAppDelegate*)APP_DELEGATE).tabBarController setSelectedIndex:1];
    searchBar.text = @"";
}

//点击view空白退出键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [mSearchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    mSearchCancelBtn.hidden = NO;
    mSearchBar.frame = CGRectMake(mSearchBar.frame.origin.x, mSearchBar.frame.origin.y, SEARCH_BAR_W-mSearchCancelBtn.frame.size.width, mSearchBar.frame.size.height);
    
    return YES;
}

- (IBAction)doSearchBarCancelButtonClicked
{
    if ([mSearchBar isFirstResponder] || ![@"" isEqualToString:mSearchBar.text]) {
        
        mSearchCancelBtn.hidden = YES;
        mSearchBar.frame = CGRectMake(mSearchBar.frame.origin.x, mSearchBar.frame.origin.y, SEARCH_BAR_W, mSearchBar.frame.size.height);
        
        mSearchBar.text = @"";
        [mSearchBar resignFirstResponder];
    }
}

@end
