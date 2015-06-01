//
//  ProductListViewController.m
//  Mall
//
//  Created by Adam on 14-12-10.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductListViewCell.h"
#import "ProductDetailViewController.h"

#define CELL_WIDTH          145

@interface ProductListViewController ()
{
    TMQuiltView *waterfallFlow;
    int indexoffset;
    
    NSMutableDictionary *imgUrlSizeDict;
    NSMutableDictionary *txtContentSizeDict;
    
    NSDictionary *backDict;
    NSDictionary *infoDict;
    
}

@property(nonatomic, copy) NSString *classIdStr;
@property(nonatomic, copy) NSString *classShowStr;

@end

@implementation ProductListViewController

@synthesize classIdStr;
@synthesize classShowStr;
@synthesize keyWord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initNaviBarView
{
    // Search
    UIImageView *typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 17, 14)];
    typeImg.image = [UIImage imageNamed:@"productItem.png"];
    
    // Item
    UIButton *btnTypeItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTypeItem addTarget:self action:@selector(doProductItem) forControlEvents:UIControlEventTouchUpInside];
    [btnTypeItem setFrame:CGRectMake(10, 0, 60, 44)];
    
    // Search
    UIImageView *searchImg = [[UIImageView alloc] initWithFrame:CGRectMake(280, 15, 14, 14)];
    searchImg.image = [UIImage imageNamed:@"productSearch.png"];
    
    // Button
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch addTarget:self action:@selector(doProductSearch) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setFrame:CGRectMake(260, 0, SCREEN_WIDTH-260, 44)];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(32, 3, 248, 20)];
    titleLable.text = @"商品列表";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    
    UILabel *subTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(32, 23, 248, 20)];
    subTitleLable.text = self.classShowStr;
    subTitleLable.font = [UIFont systemFontOfSize:12.0f];
    subTitleLable.textColor = [UIColor whiteColor];
    subTitleLable.textAlignment = NSTextAlignmentCenter;
    
    // navi
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    
    [naviView addSubview:typeImg];
    [naviView addSubview:btnTypeItem];
    [naviView addSubview:titleLable];
    [naviView addSubview:subTitleLable];
    [naviView addSubview:searchImg];
    [naviView addSubview:btnSearch];
    
    self.navigationItem.titleView = naviView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showOrHideTabBar:NO];
    
    if ([AppManager instance].productKeyWord && ![@"" isEqualToString:[AppManager instance].productKeyWord]) {
        
        self.classIdStr = @"";
        self.classShowStr = @"全部商品";
        self.keyWord = [AppManager instance].productKeyWord;
        [self loadProductListData];
        [self initNaviBarView];
        
        indexoffset = 0;
        
        [AppManager instance].productKeyWord = @"";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.classShowStr = @"所有商品";
    self.keyWord = @"";
    
    [self initNaviBarView];
    
    imgUrlSizeDict = [NSMutableDictionary dictionary];
    txtContentSizeDict = [NSMutableDictionary dictionary];
    
    tbdataAry = [NSMutableArray array];
    
    indexoffset = 0;
    [self loadProductListData];
    
}

//// view did will appear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustView
{
    waterfallFlow.alpha = 0;
    
    [self.view addSubview:self.noNetWorkView];
}

// 初始化刷新视图
-(void)initHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0, 0.0f - self.view.bounds.size.height,
                                     SCREEN_WIDTH, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
    [waterfallFlow addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)finishedLoadData
{
    [self finishReloadingData];
    [self initFootView];
}

- (void)finishReloadingData
{
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:waterfallFlow];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:waterfallFlow];
        [self initFootView];
    }
}

- (void)initFootView
{
    CGFloat hegiht = MAX(waterfallFlow.contentSize.height, waterfallFlow.frame.size.height);
    
    if (_refreshFooterView && [_refreshFooterView superview]) {
        _refreshFooterView.frame = CGRectMake(0, hegiht, waterfallFlow.frame.size.width, self.view.bounds.size.height);
    } else {
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0, hegiht, waterfallFlow.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [waterfallFlow addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

- (void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    
    _refreshFooterView = nil;
}

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        
        [self performSelector:@selector(getLastestPageView) withObject:nil afterDelay:2.0];
    } else if(aRefreshPos == EGORefreshFooter) {
        
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
}

- (void) getLastestPageView
{
    indexoffset = 0;
    [self loadProductListData];
}

#pragma mark - 下拉刷新加载
- (void) getNextPageView
{
    
    indexoffset += 10;
    [self loadProductListData];
}

#pragma mark - UIScrollViewDelegate methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - EGORefreshTableDelegate methods
- (void) egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL) egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate *) egoRefreshTableDataSourceLastUpdated:(UIView *)view
{
    return [NSDate date];
}

#pragma mark - 调用商品列表
- (void) loadProductListData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.classIdStr == nil ? @"" : self.classIdStr forKey:@"class_id"];
    [dataDict setObject:@"1" forKey:@"product_type"];
    [dataDict setObject:self.keyWord == nil ? @"" : self.keyWord forKey:@"search_info"];
    [dataDict setObject:@(indexoffset) forKey:@"offset"];
    [dataDict setObject:@"10" forKey:@"num"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_getproductlist"
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
                                         [self performSelector:@selector(finishedLoadData) withObject:nil afterDelay:0];
                                     }];
                                     
                                 } else {
                                     
                                     if (waterfallFlow == nil) {
                                         
                                         waterfallFlow = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-kTabBarHeight)];
                                         waterfallFlow.delegate = self;
                                         waterfallFlow.dataSource = self;
                                         
                                         [self.view addSubview:waterfallFlow];
                                     }
                                     
                                     //解析网络json
                                     backDict = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDict);
                                     //  拿到字典的字典的数组里面的数据
                                     NSArray *backArray = [[backDict valueForKey:@"data"] valueForKey:@"lists"];
                                     
                                     waterfallFlow.showsVerticalScrollIndicator = NO;
                                     
                                     if ([backArray count] > 0) {
                                         //判断网络json解析出来的是否是数组
                                         if ([backArray isKindOfClass:[NSArray class]]) {
                                             
                                             if (indexoffset == 0) {
                                                 
                                                 if (tbdataAry && tbdataAry.count > 0) {
                                                     [tbdataAry removeAllObjects];
                                                 }
                                             }
                                             
                                             [tbdataAry addObjectsFromArray:backArray];
                                             
                                             if ([tbdataAry count] > 0)
                                             {
                                                 
                                                 [waterfallFlow reloadData];
                                                 
                                                 if (self.noNetWorkView.superview) {
                                                     [self.noNetWorkView removeFromSuperview];
                                                     waterfallFlow.alpha = 1;
                                                 }
                                             }
                                         }
                                         
                                         [self initHeaderView];
                                     } else {
                                         
                                         if (indexoffset == 0) {
                                             // 第一页没有内容
                                             [self.view addSubview:self.noNetWorkView];
                                         } else {
                                             // 多级页面没有内容
                                             if (tbdataAry.count == 0) {
                                                 [self.view addSubview:self.noNetWorkView];
                                             }
                                         }
                                     }
                                     
                                     [self performSelector:@selector(finishedLoadData) withObject:nil afterDelay:0];
                                 }
                             }];
     }];
}

- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@", [tbdataAry [indexPath.row] valueForKey:@"thumbnail_url"]];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //Nothing.
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //Nothing.
    }];
    
    CGSize targetSize = CGSizeMake(CELL_WIDTH, CELL_WIDTH * imageView.image.size.height / imageView.image.size.width);
    
    [imgUrlSizeDict setObject:@(targetSize.height) forKey:imageUrl];
    
    return [CommonUtils imageScaleToSize:imageView.image size:targetSize];
}

#pragma mark - product detail
- (CGFloat)productDetailHeight:(NSIndexPath *)indexPath offsetHeight:(CGFloat)offsetHeight
{
    NSString *productName = [infoDict objectForKey:@"product_name"];
    
    NSString *slogan = [infoDict objectForKey:@"slogan"];
    int sloganLen = 0;
    
    NSString *productDesc = nil;
    
    if (slogan.length) {
        sloganLen = [slogan length];
        productDesc = [NSString stringWithFormat:@"%@ %@", productName, slogan];
    } else {
        productDesc = productName;
    }
    
    CGRect productDescRect = [CommonUtils sizeWithText:productDesc withFont:[UIFont systemFontOfSize:12.f] size:CGSizeMake(CELL_WIDTH-16, MAXFLOAT)];
    
    CGFloat backVal = productDescRect.size.height + 50;
    
    [txtContentSizeDict setObject:@(backVal) forKey:[infoDict objectForKey:@"product_id"]];
    
    return backVal;
}

- (UIView *)productDetailView:(NSIndexPath *)indexPath offsetHeight:(CGFloat)offsetHeight
{
    //简介
    UIView *productBG = [[UIView alloc] init];
    
    UILabel *productDesc = [[UILabel alloc] init];
    productDesc.textColor = HEX_COLOR(@"0x646464");
    productDesc.font = [UIFont systemFontOfSize:12.f];
    productDesc.numberOfLines = 0;
    
    NSString *productName = [infoDict objectForKey:@"product_name"];
    int nameLen = [productName length];
    
    NSString *slogan = [infoDict objectForKey:@"slogan"];
    int sloganLen = 0;
    
    if (slogan.length) {
        sloganLen = [slogan length];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", productName, slogan]];
        
        [attributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:11.f]
                              range:NSMakeRange(nameLen+1, sloganLen-1)];
        [attributedStr addAttribute:NSForegroundColorAttributeName
                              value:HEX_COLOR(@"0xf86052")
                              range:NSMakeRange(nameLen+1, sloganLen)];
        
        productDesc.attributedText = attributedStr;
    } else {
        productDesc.text = productName;
    }
    
    CGRect productDescRect = [CommonUtils sizeWithText:productDesc.attributedText.string withFont:productDesc.font size:CGSizeMake(CELL_WIDTH-16, MAXFLOAT)];
    productDesc.frame = CGRectMake(8, 6, CELL_WIDTH-16, productDescRect.size.height);
    
    // 将商品加入view
    [productBG addSubview:productDesc];
    
    UITableViewCell *saleCell = [[[NSBundle mainBundle] loadNibNamed:@"ProductListSaleCell" owner:self options:nil] lastObject];
    saleCell.contentView.frame = CGRectMake(0, productDesc.frame.origin.y + productDesc.frame.size.height, CELL_WIDTH, 50);
    UILabel *memberPrice = (UILabel *)[saleCell.contentView viewWithTag:10];
    UILabel *price = (UILabel *)[saleCell.contentView viewWithTag:11];
    UILabel *saleNumber = (UILabel *)[saleCell.contentView viewWithTag:12];
    UILabel *commentNumber = (UILabel *)[saleCell.contentView viewWithTag:13];
    
    memberPrice.text = [NSString stringWithFormat:@"￥%@", [infoDict objectForKey:@"price"]];
    price.text = [NSString stringWithFormat:@"原价: %@", [infoDict objectForKey:@"basic_price"]];
    saleNumber.text = [NSString stringWithFormat:@"已售出%@件", [infoDict objectForKey:@"sale_count"]];
    commentNumber.text = [NSString stringWithFormat:@"%@", [infoDict objectForKey:@"comment_count"]];
    
    // discount line
    UIView *discountLine = (UIView*)[saleCell viewWithTag:14];
    discountLine.frame = CGRectMake(discountLine.frame.origin.x, discountLine.frame.origin.y, [CommonUtils sizeWithText:price.text withFont:price.font size:CGSizeMake(CGFLOAT_MAX, price.frame.size.height)].size.width, 1);
    
    [productBG addSubview:saleCell.contentView];
    
    productBG.frame = CGRectMake(0, offsetHeight, CELL_WIDTH, productDescRect.size.height + 50);
    
    return productBG;
}

#pragma mark - 显示多少条数据
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView
{
    return tbdataAry.count;
}

#pragma mark - 显示cell的数据
- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"ProductListCell";
    ProductListViewCell *cell = (ProductListViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[ProductListViewCell alloc] initWithReuseIdentifier:cellID];
    }
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    infoDict = [tbdataAry objectAtIndex:indexPath.row];
    
    cell.photoView.image = [self imageAtIndexPath:indexPath];
    
    cell.detailsView = [self productDetailView:indexPath offsetHeight:cell.photoView.image.size.height];
    
    return cell;
    
}

#pragma mark 显示多少行多少列
- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 1;
    } else {
        return 2;
    }
}

#pragma mark - 图片的高度
- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellH = 0.f;
    
    infoDict = [tbdataAry objectAtIndex:indexPath.row];
    
    if (infoDict) {
        NSString *imgUrl = [infoDict valueForKey:@"thumbnail_url"];
        CGFloat imgH = 0.f;
        
        if ([imgUrlSizeDict objectForKey:imgUrl]) {
            imgH = [[imgUrlSizeDict objectForKey:imgUrl] floatValue];
        } else {
            imgH = [self imageAtIndexPath:indexPath].size.height;
        }
        
        NSString *productId = [infoDict valueForKey:@"thumbnail_url"];
        if ([txtContentSizeDict objectForKey:productId]) {
            cellH = [[txtContentSizeDict objectForKey:productId] floatValue] + imgH;
        } else {
            cellH = [self productDetailHeight:indexPath offsetHeight:imgH] + imgH;
        }
    }
    
    return cellH;
}

#pragma mark 点击图片跳转到详情页面
- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    infoDict = [tbdataAry objectAtIndex:indexPath.row];
    ProductDetailViewController *merPlist = [[ProductDetailViewController alloc] init];
    merPlist.productId = [infoDict objectForKey:@"product_id"];
    self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:0 target:nil action:nil];
    [self.navigationController pushViewController:merPlist animated:YES];
}

#pragma mark - logic handle
- (void)doProductItem
{
    [self openDrawer:nil];
}

- (void)doProductSearch
{
    [self openDrawer:nil];
}

#pragma mark - ICSDrawerControllerPresenting method

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
    [self showOrHideTabBar:NO];
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
    [self showOrHideTabBar:NO];
}

#pragma mark - Open drawer button

- (void)openDrawer:(id)sender
{
    [self.drawer open];
}

- (void)clickType:(NSString*)aKeyWord classIdStr:(NSString *)aClassIdStr classShowStr:(NSString *)aClassShowStr
{
    self.keyWord = aKeyWord;
    self.classIdStr = aClassIdStr;
    self.classShowStr = aClassShowStr;
    
    [self initNaviBarView];
    
    indexoffset = 0;
    
    [self loadProductListData];
}

- (void)btnNoNetWorkClicked:(id)sender
{
    [self loadProductListData];
}

@end
