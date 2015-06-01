//
//  ProductDetailViewController.m
//  Mall
//
//  Created by Adam on 14-12-9.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "CommonWebViewController.h"
#import "HomeViewController.h"
#import "BuyNowViewController.h"
#import "ProductCommentsViewController.h"
#import "ShoppingCartViewController.h"
#import "ExperienceViewController.h"
#import "LoginViewController.h"

#import "WXApi.h"

#define SCROLL_H            225
#define PAY_NUMBER_TAG      2001
#define STORE_NUMBER_TAG    2002
#define SKU_SIZE_TAG        2003

typedef enum {
    FLOAT_CART_BTN_TAG = 3001,
    FLOAT_CART_NUMBER_TAG,
    FLOAT_EXPERIENCE_BTN_TAG,
    FLOAT_EXPERIENCE_NUMBER_TAG,
} FLOAT_ACTION_BTN_TAG;

typedef enum {
    PAY_BTN_TAG = 4001,
    FAVORITE_BTN_TAG,
    CART_BTN_TAG,
    EXPERIENCE_BTN_TAG,
} ACTION_BTN_TAG;

#define CommentNumber 100
#define COMMENTSX 36.3f
#define COMMENTSH 28

#define BORDERTAG 1100

@interface ProductDetailViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    int sizeCount;
    
    NSMutableArray *backCommentArray;
    NSMutableArray *backDataArray;
    
    UIView *backView;//蒙板view
    UIView *comments;//提交评论view
    UITextView *productContentsText;//评论textview
    
    int goodsCommentsImgNumber;
    UIButton *selectButImg;
    UIButton *selectButExpImg;
    
    int addCartState;
    
    BOOL isShow;
}

@property (nonatomic, copy) NSString* cartId;
@property (nonatomic, copy) NSString* productImgUrl;
@property (nonatomic, copy) NSString* skuId;
@property (nonatomic, copy) NSString* skuQty;
@property (nonatomic, copy) NSString* skuSize;
@property (nonatomic, copy) NSString* memberPriceMsg;

@property (nonatomic, retain) UIView *windowPopView;
@property (nonatomic, retain) UIView *windowBgView;

@end

@implementation ProductDetailViewController
{
    int slideCount;
}

@synthesize windowBgView, windowPopView;

@synthesize scrollView, pageControl;
@synthesize popScrollView, popPageControl;
@synthesize productId;
@synthesize mTableView;
@synthesize carBG;

@synthesize cartId, skuId, skuQty, skuSize, productImgUrl, memberPriceMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initiscrollViewalization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showOrHideTabBar:YES];

}

#pragma mark - 进入视图所进入的第一个方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"商品详情";
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [rightButton setImage:[UIImage imageNamed:@"icon79.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    selectButImg = [[UIButton alloc] initWithFrame:CGRectMake(63, 62, 30, 30)];
    selectButExpImg = [[UIButton alloc] initWithFrame:CGRectMake(200, 62, 30, 30)];
    
    [self loadProductData];
    [self loadCommentData];
}

- (void)adjustView
{
    mTableView.alpha = 0;
    
    [self.view addSubview:self.noNetWorkView];
    
    int tableH = SCREEN_HEIGHT - self.carBG.frame.size.height - 64 - 10;
    self.carBG.frame = CGRectMake(self.carBG.frame.origin.x, tableH, self.carBG.frame.size.width, self.carBG.frame.size.height);
}

#pragma mark - UIScrollViewDelegate method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (sender == scrollView) {
        pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    } else if(sender == popScrollView) {
        popPageControl.currentPage = (int)(popScrollView.contentOffset.x / popScrollView.frame.size.width);
    }
    
}

#pragma mark - 点击蒙板返回评论页面
- (void)dismissView
{
    [comments removeFromSuperview];
    [backView removeFromSuperview];
}

#pragma mark - 点击提交按钮
- (void)submitComments
{
    NSLog(@"%@",productContentsText.text);
    if (nil == productContentsText.text || [productContentsText.text isEqualToString:@""] || goodsCommentsImgNumber == 0) {
        
        [self showTimeAlert:@"提示:" message:@"您忘记评论或评分了!"];
    } else {
        [self createComment];
    }
}

#pragma mark - 键盘退出
- (void)dismissKeyBoard
{
    [productContentsText resignFirstResponder];
}

#pragma mark - 评分
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

#pragma mark - 点击我要评论
- (void)doCommentsBtn
{
    NSLog(@"我要评论");
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
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
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard)];
    productContentsText = [[UITextView alloc] initWithFrame:CGRectMake(productContents.frame.origin.x, productContents.frame.origin.y + 25, 300, 80)];
    productContentsText.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    [productContentsText.layer setBorderWidth:1];
    productContentsText.layer.borderColor  = [[UIColor blackColor]CGColor];
    //goodsContentsText.text = @"哈哈好";
    UIButton *submitContents = [[UIButton alloc] initWithFrame:CGRectMake(122,205, 80, 30)];
    [submitContents.layer setBorderWidth:1];
    submitContents.layer.cornerRadius=8;
    [submitContents.layer setMasksToBounds:YES];
    [submitContents setBackgroundColor:[UIColor redColor]];
    submitContents.layer.borderColor = [[UIColor redColor] CGColor];
    [submitContents setTintColor:[UIColor whiteColor]];
    [submitContents setTitle:@"提交" forState:UIControlStateNormal];
    [submitContents addTarget:self action:@selector(submitComments) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tapGestureview = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
    [comments addGestureRecognizer:tapGesture];
    
    [comments addSubview:productScore];
    [comments addSubview:productContents];
    [comments addSubview:productContentsText];
    [backView addGestureRecognizer:tapGestureview];
    [comments addSubview:submitContents];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:comments];
}

#pragma mark - 初始化uiview 显示商品评论
- (void)initTableFooter
{
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  260)];
    
    UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [splitView setBackgroundColor:HEX_COLOR(@"0xd3d3d3")];
    [footview addSubview:splitView];
    
    UIButton *CommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(100.5, 20, 119, 36)];
    [CommentBtn.layer setBorderWidth:1];
    CommentBtn.layer.cornerRadius=4;
    [CommentBtn.layer setMasksToBounds:YES];
    [CommentBtn setBackgroundColor:HEX_COLOR(@"0xf86052")];
    CommentBtn.layer.borderColor = [HEX_COLOR(@"0xf86052") CGColor];
    [CommentBtn setTitle:@"我要评论" forState:UIControlStateNormal];
    [CommentBtn addTarget:self action:@selector(doCommentsBtn) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:CommentBtn];
    
    self.mTableView.tableFooterView = footview;
}

#pragma mark - 初始化scrollview 显示轮播图片
- (void)initTableHeader:(NSArray *)imageArr
{
    
    // Clean
    self.mTableView.tableHeaderView = nil;
    
    // Init
    CGRect scrollFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_H);
    UIView *headview = [[UIView alloc] initWithFrame:scrollFrame];
    
    // 初始化 数组 并添加图片
    slideCount = [imageArr count];
    
    // 初始化 scrollview
    scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.contentSize = CGSizeMake(0,0);//scrollview能拖动的范围
    scrollView.bounces = YES;
    //默认是 yes，就是滚动超过边界会反弹有反弹回来的效果。假如是 NO，那么滚动到达边界会立刻停止。
    scrollView.pagingEnabled = YES;//当值是 YES 会自动滚动到 subview 的边界。默认是NO
    scrollView.userInteractionEnabled = YES;//
    scrollView.showsHorizontalScrollIndicator = NO;//滚动时是否显示水平滚动条
    scrollView.delegate = self;
    [headview addSubview:scrollView];
    
    // 创建图片 imageview
    __block float imageW = SCREEN_WIDTH;
    for (int i = 0; i<slideCount; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[imageArr objectAtIndex:i]] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
            // imageView.image = image;
            imageW = (imageView.image.size.width * SCROLL_H) / imageView.image.size.height;
            if (imageW > SCREEN_WIDTH) {
                imageW = SCREEN_WIDTH;
            }
            
            CGSize targetSize = CGSizeMake(imageW, SCROLL_H);
            imageView.image = [CommonUtils imageScaleToSize:imageView.image size:targetSize];
        }];
        
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, scrollFrame.size.width, scrollFrame.size.height);
        imageView.contentMode = UIViewContentModeCenter;
        
        imageView.backgroundColor = [UIColor whiteColor];
        
        [scrollView addSubview:imageView];
    }
    
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureview = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openBigImage:)];
    [scrollView addGestureRecognizer:tapGestureview];
    
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * slideCount, scrollFrame.size.height)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    // 初始化 pagecontrol
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 206, SCREEN_WIDTH, 13)];
    [pageControl setCurrentPageIndicatorTintColor:HEX_COLOR(@"0xfa5e4f")];
    [pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    pageControl.numberOfPages = slideCount;
    pageControl.currentPage = 0;
    [headview addSubview:pageControl];
    
    self.mTableView.tableHeaderView = headview;
    
    [self loadPopScrollView:imageArr];
}

- (void)loadPopScrollView:(NSArray *)imageArr
{
    // BackGround view
    windowBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    windowBgView.backgroundColor = [UIColor blackColor];
    
    // pop view
    CGRect scrollFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    windowPopView = [[UIView alloc] initWithFrame:scrollFrame];
    
    // 初始化 scrollview
    popScrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    popScrollView.contentSize = CGSizeMake(0,0);//scrollview能拖动的范围
    popScrollView.bounces = YES;
    //默认是 yes，就是滚动超过边界会反弹有反弹回来的效果。假如是 NO，那么滚动到达边界会立刻停止。
    popScrollView.pagingEnabled = YES;//当值是 YES 会自动滚动到 subview 的边界。默认是NO
    popScrollView.userInteractionEnabled = YES;//
    popScrollView.showsHorizontalScrollIndicator = NO;//滚动时是否显示水平滚动条
    popScrollView.delegate = self;
    [windowPopView addSubview:popScrollView];
    
    // 创建图片 imageview
    __block float imageW = SCREEN_WIDTH;
    for (int i = 0; i<slideCount; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[imageArr objectAtIndex:i]] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //Nothing.
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //Nothing.
            imageW = (imageView.image.size.width * SCROLL_H) / imageView.image.size.height;
            if (imageW >= SCREEN_WIDTH) {
                imageW = SCREEN_WIDTH;
            }
            
            CGSize targetSize = CGSizeMake(imageW, SCROLL_H);
            imageView.image = [CommonUtils imageScaleToSize:imageView.image size:targetSize];
        }];
        
        
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, scrollFrame.size.width, scrollFrame.size.height);
        imageView.contentMode = UIViewContentModeCenter;
        
        [popScrollView addSubview:imageView];
    }
    
    popScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureview = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openBigImage:)];
    [popScrollView addGestureRecognizer:tapGestureview];
    
    [popScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * slideCount, scrollFrame.size.height)];
    [popScrollView setContentOffset:CGPointMake(0, 0)];
    
    // 初始化 pagecontrol
    self.popPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 406, SCREEN_WIDTH, 13)];
    [popPageControl setCurrentPageIndicatorTintColor:HEX_COLOR(@"0xfa5e4f")];
    [popPageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    popPageControl.numberOfPages = slideCount;
    popPageControl.currentPage = 0;
    [windowPopView addSubview:popPageControl];
    
}

#pragma mark - 点击商品颜色改变边框
- (void)changeSize:(UIButton *)but
{
    NSDictionary *skuDict = [[backDataArray valueForKey:@"skus"] valueForKey:@"lists"];
    
    for (int i = 0 ; i < [[skuDict valueForKey:@"thumbnail_urls"] count]; i++) {
        
        UIButton *btnChangeColor = (UIButton *)[self.view viewWithTag:BORDERTAG+i];
        
        if (btnChangeColor.tag == but.tag) {
            
            // 赋值
            self.skuId = [skuDict valueForKey:@"sku_id"][i];
            self.skuSize = [[skuDict valueForKey:@"sku_total_stock"][i] valueForKey:@"size"][0];
            
            // 样式改变
            [btnChangeColor.layer setBorderColor:HEX_COLOR(@"0xf86052").CGColor];
            [btnChangeColor.layer setBorderWidth:0.8];
            
            UILabel *stockName = (UILabel *)[self.view viewWithTag:STORE_NUMBER_TAG];
            stockName.text = [NSString stringWithFormat:@"库存(%@)件", [[skuDict valueForKey:@"sku_total_stock"][i] valueForKey:@"count"][0]];
            
            int sizeNameWidth = [CommonUtils sizeWithText:self.skuSize withFont:[UIFont systemFontOfSize:14.f] size:CGSizeMake(MAXFLOAT, 28)].size.width;
            
            UIButton *butSize = (UIButton *)[self.view viewWithTag:SKU_SIZE_TAG];
            butSize.frame = CGRectMake(71, 44, sizeNameWidth+5, 28);
            [butSize setTitle:self.skuSize forState:UIControlStateNormal];
            
            NSDictionary *skuDict = [[backDataArray valueForKey:@"skus"] valueForKey:@"lists"];
            NSArray *imageArr = [skuDict valueForKey:@"thumbnail_urls"][i];
            
            [self initTableHeader:imageArr];
            
        } else {
            [btnChangeColor.layer setBorderWidth:0];
        }
    }
}

#pragma mark - 商品数量＋1
- (void)doAddCount:(id)sender
{
    UIButton *btnAdd = (UIButton *)sender;
    
    UIView *cellContentView = [btnAdd superview];
    UITextField *numberTxt = (UITextField *)[cellContentView viewWithTag:PAY_NUMBER_TAG];
    int intVal = [numberTxt.text intValue];
    
    intVal++;
    
    numberTxt.text = [NSString stringWithFormat:@"%d", intVal];
    self.skuQty = numberTxt.text;
}

#pragma mark - 商品数量-1
- (void)doSubCount:(id)sender
{
    UIButton *btnSub = (UIButton *)sender;
    
    UIView *cellContentView = [btnSub superview];
    UITextField *numberTxt = (UITextField *)[cellContentView viewWithTag:PAY_NUMBER_TAG];
    int intVal = [numberTxt.text intValue];
    
    intVal --;
    
    if (intVal <= 1) {
        intVal = 1;
    }
    
    numberTxt.text = [NSString stringWithFormat:@"%d", intVal];
    self.skuQty = numberTxt.text;
}

#pragma mark - 加入购物车动画效果
- (void)doAddToCartAnimal:(id)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doAddToCartAnimalM:ethod:) object:sender];
    [self performSelector:@selector(doAddToCartAnimalMethod:) withObject:sender afterDelay:0.2f];
}

- (void)doAddToCartAnimalMethod:(id)sender
{
    if (![self isLogined]) {
        
        return;
    }
    
    UIButton *shopCarBt = (UIButton*)[self.view viewWithTag:FLOAT_CART_BTN_TAG];
    selectButImg.hidden = NO;
    
    UIButton *btnAddToCart = (UIButton *)sender;
    UITableViewCell *cartTabCell = (UITableViewCell *)[[btnAddToCart superview] superview];
    
    // 动画 [起点, 终点] 都以sel.view为参考系
    CGPoint startPoint = [self.view convertPoint:CGPointMake(cartTabCell.frame.origin.x + btnAddToCart.frame.origin.x + btnAddToCart.frame.size.width/4, cartTabCell.frame.origin.y + btnAddToCart.frame.origin.y) fromView:self.mTableView];
    CGPoint endPoint = [self.view convertPoint:shopCarBt.center fromView:self.carBG];
    
    // 贝塞尔曲线
    float sx = startPoint.x;
    float sy = startPoint.y;
    float ex = endPoint.x;
    float ey = endPoint.y;
    float x = sx + (ex - sx) / 3;
    float y = sy + (ey - sy) * 0.5 - 400;
    
    CGPoint centerPoint = CGPointMake(x, y);

    // 贝塞尔
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:startPoint];
    [movePath addQuadCurveToPoint:endPoint controlPoint:centerPoint];
    
    // 关键帧
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = movePath.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1.f;
    animation.delegate = self;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.rotationMode = kCAAnimationRotateAuto;
    
    // Layer
    selectButImg.layer.opacity = 0.6;
    [self.view.layer addSublayer:selectButImg.layer];
    
    [selectButImg.layer addAnimation:animation forKey:@"buy"];
    
    [self performSelector:@selector(doAddToCartFinished)
               withObject:selectButImg.layer
               afterDelay:1.f];

}

- (void)doAddToCartFinished
{
    if (![self isLogined]) {
        
        return;
    }
    
    UIButton *shoppingBut = (UIButton *)[self.view viewWithTag:FLOAT_CART_NUMBER_TAG];
    shoppingBut.layer.cornerRadius = 7.5;
    [shoppingBut.layer setMasksToBounds:YES];
    shoppingBut.hidden = NO;
    
    int shoppingCount = [shoppingBut.titleLabel.text intValue];
    NSString *strInt = [NSString stringWithFormat:@"%d", shoppingCount+1];
    [shoppingBut setTitle:strInt forState:UIControlStateNormal];
    
    addCartState = 1;
    [self doAddToCartLogic:@"0"];
}

- (void)doAddToCartLogic:(NSString *)cartType
{
    /**
        product_id:商品id
        sku_id:商品sku_id
        sku_qty:加入购物车的数量。这里暂时传1
        size:商品规格
        cart_type:购物车的类别，0：在线购物车，1：到店体验车
        from:加入购物车的商品的来源，默认为product,如果是从收藏加入的购物车，请传fav
    */
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    [dataDict setObject:self.skuId forKey:@"sku_id"];
    [dataDict setObject:self.skuQty forKey:@"sku_qty"];
    [dataDict setObject:self.skuSize forKey:@"size"];
    [dataDict setObject:cartType forKey:@"cart_type"];
    [dataDict setObject:@"product" forKey:@"from"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_addtoshoppingcart"
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
                                         
                                         self.cartId = [[backDic valueForKey:@"data"] objectForKey:@"cart_id"];
                                         self.productImgUrl = [[[backDic valueForKey:@"data"] objectForKey:@"product_info"] objectForKey:@"thumbnail_url"];
                                         
                                         NSString *productName = [backDataArray valueForKey:@"product_name"];
                                         
                                         if (self.cartId != nil && self.cartId.length > 0) {

                                             switch (addCartState) {
                                                 case 0:
                                                 {
                                                     BuyNowViewController *buy = [[BuyNowViewController alloc] init];
                                                     [buy updateData:self.cartId skuId:self.skuId skuQty:self.skuQty skuSize:self.skuSize productImgUrl:self.productImgUrl productName:productName priceValue:self.memberPriceMsg];
                                                     [self.navigationController pushViewController:buy animated:YES];
                                                 }
                                                     break;
                                                     
                                                 case 1:
                                                 {
                                                     [self showHUDWithText:@"加入购物车成功!"];
                                                     break;
                                                 }
                                                     
                                                 case 2:
                                                 {
                                                     [self showHUDWithText:@"预约体验成功!"];
                                                     break;
                                                 }
                                                     
                                                 default:
                                                     break;
                                             }
                                         }
                                     }
                                 }
                             }];
     }];
}

#pragma mark - 预约体验单动画效果
- (void)doAddExperienceAnimal:(id)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doAddExperienceAnimalMethod:) object:sender];
    [self performSelector:@selector(doAddExperienceAnimalMethod:) withObject:sender afterDelay:0.2f];
}

- (void)doAddExperienceAnimalMethod:(id)sender
{
    if (![self isLogined]) {
        
        return;
    }
    
    UIButton *shopCarBt = (UIButton*)[self.view viewWithTag:FLOAT_EXPERIENCE_BTN_TAG];
    selectButExpImg.hidden = NO;
    
    UIButton *btnAddToCart = (UIButton *)sender;
    UITableViewCell *cartTabCell = (UITableViewCell *)[[btnAddToCart superview] superview];
    
    // 动画 [起点, 终点] 都以sel.view为参考系
    CGPoint startPoint = [self.view convertPoint:CGPointMake(cartTabCell.frame.origin.x + btnAddToCart.frame.origin.x + btnAddToCart.frame.size.width/4, cartTabCell.frame.origin.y + btnAddToCart.frame.origin.y) fromView:self.mTableView];
    CGPoint endPoint = [self.view convertPoint:shopCarBt.center fromView:self.carBG];
    
    // 贝塞尔曲线
    float sx = startPoint.x;
    float sy = startPoint.y;
    float ex = endPoint.x;
    float ey = endPoint.y;
    float x = sx + (ex - sx) / 3;
    float y = sy + (ey - sy) * 0.5 - 400;
    
    CGPoint centerPoint = CGPointMake(x, y);
    
    // 贝塞尔
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:startPoint];
    [movePath addQuadCurveToPoint:endPoint controlPoint:centerPoint];
    
    //关键帧
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = movePath.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1.f;
    animation.delegate = self;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.rotationMode = kCAAnimationRotateAuto;
    
    // Layer
    selectButExpImg.layer.opacity = 0.6;
    [self.view.layer addSublayer:selectButExpImg.layer];
    
    [selectButExpImg.layer addAnimation:animation forKey:@"buy"];
    
    [self performSelector:@selector(doAddToExperienceFinished)
               withObject:selectButExpImg.layer
               afterDelay:1.f];
}

- (void)doAddToExperienceFinished
{
    UIButton *btnExperience = (UIButton *)[self.view viewWithTag:FLOAT_EXPERIENCE_NUMBER_TAG];
    btnExperience.layer.cornerRadius = 7.5;
    [btnExperience.layer setMasksToBounds:YES];
    btnExperience.hidden = NO;
    
    int shoppingCount = [btnExperience.titleLabel.text intValue];
    NSLog(@"%d", shoppingCount);
    NSString *strInt = [NSString stringWithFormat:@"%d", shoppingCount+1];
    NSLog(@"%@", strInt);
    [btnExperience setTitle:strInt forState:UIControlStateNormal];
    NSLog(@"%@", btnExperience.titleLabel.text);
    
    addCartState = 2;
    
    [self doAddToCartLogic:@"1"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"开始动画");
}

#pragma mark - animal finish
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    selectButImg.hidden = YES;
    selectButExpImg.hidden = YES;
    NSLog(@"结束动画");
}

#pragma mark - UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 6;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    
    switch (section) {
            
        case 0:
        {
            if (backDataArray != nil) {
                
                if (row == 0) {
                    
                    return [self getProductDescHeight];
                } else {
                    
                    NSString *pointNum = [backDataArray valueForKey:@"earn_point"];
                    
                    if (![pointNum isEqualToString:@"0"]) {
                        return 68;
                    } else {
                        return 40;
                    }
                }
            } else {
                
                if (row == 0) {
                    return 56;
                } else {
                    return 40;
                }
            }
        }
            
            break;
            
        case 1:
        {
            NSString *specStr1 = [backDataArray valueForKey:@"spec2_text"];
            NSString *specStr2 = [backDataArray valueForKey:@"spec1_text"];
            
            int height = 55;
            if (specStr1.length > 0) {
                height += 75;
            }
            
            if (specStr2.length > 0) {
                
                NSDictionary *skuDict = [[backDataArray valueForKey:@"skus"] valueForKey:@"lists"];
                NSArray* colorArray = [skuDict valueForKey:@"thumbnail_urls"];
                int colorCount = [colorArray count];
                
                int colorLine = colorCount / 5;
                if (colorCount % 5 != 0) {
                    colorLine ++;
                }
                
                height += (45 * colorLine + 10);
//                height += 45;
            }
            
            return height;
        }
            
        case 2:
            return 99;
            
        case 3:
        case 4:
            return 45;
            
        case 5:
        {
            CGFloat contentH = [self getContentHeight:indexPath];
            
            if (contentH + 50 > 100) {
                return contentH + 50;
            }
            
            return 100;
        }
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark - 返回tableview的行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (backCommentArray && [backCommentArray count] > 0) {
        return 6;
    }
    
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
        case 2:
        case 3:
        case 4:
            return 1;
            break;
            
        case 5:
        {
            if (backCommentArray && [backCommentArray count] > 0) {
                int commentCount = [backCommentArray count];
                if (commentCount >= 3) {
                    return 3;
                } else {
                    return commentCount;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark - 点击cell行触发事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 3) {
        NSLog(@"商品介绍");
        
        CommonWebViewController *webVC = [[CommonWebViewController alloc] init];
        webVC.strTitle = @"商品介绍";
        webVC.strUrl = [NSString stringWithFormat:@"%@?cid=%@&user_id=%@&open_id=123&pid=%@", WEB_URL, CID_PARAM, USER_PARAM, productId];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
    if (section == 4) {
        
        NSLog(@"商品评论");
        ProductCommentsViewController *pcVC = [[ProductCommentsViewController alloc] init];
        pcVC.productId = productId;
        [self.navigationController pushViewController:pcVC animated:YES];
    }
}

#pragma mark - 初始化商品详情的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            
            if (row == 0) {
                
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                UILabel *productDesc = [[UILabel alloc] init];
                productDesc.textColor = HEX_COLOR(@"0x444444");
                productDesc.font = [UIFont systemFontOfSize:15.f];
                productDesc.numberOfLines = 0;
                
                NSString *productName = [backDataArray valueForKey:@"product_name"];
                int nameLen = [productName length];
                
                NSString *slogan = [backDataArray valueForKey:@"slogan"];
                int sloganLen = 0;
                
                if (slogan.length) {
                    sloganLen = [slogan length];
                    
                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", productName, slogan]];
                    
                    [attributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:14.f]
                                          range:NSMakeRange(nameLen+1, sloganLen-1)];
                    [attributedStr addAttribute:NSForegroundColorAttributeName
                                          value:HEX_COLOR(@"0xf86052")
                                          range:NSMakeRange(nameLen+1, sloganLen)];
                    
                    productDesc.attributedText = attributedStr;
                } else {
                    productDesc.text = productName;
                }
                
                CGRect productRect = [productDesc.attributedText boundingRectWithSize:CGSizeMake(productDesc.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                productDesc.frame = CGRectMake(11, 13, SCREEN_WIDTH-22, productRect.size.height);
                
                [cell.contentView addSubview:productDesc];
                [productDesc sizeToFit];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                
                UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductSaleView" owner:self options:nil] lastObject];
                
                UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
                [splitView setBackgroundColor:HEX_COLOR(@"0xd3d3d3")];
                [cell.contentView addSubview:splitView];
                
                UILabel *memberPriceName = (UILabel*)[cell viewWithTag:10];
                memberPriceName.text = [NSString stringWithFormat:@"¥%@", self.memberPriceMsg];
                
                UILabel *priceName = (UILabel*)[cell viewWithTag:11];
                priceName.text = [NSString stringWithFormat:@"¥%@", [backDataArray valueForKey:@"basic_sku_product_price"]];
                
                // discount line
                UIView *discountLine = (UIView*)[cell viewWithTag:13];
                discountLine.frame = CGRectMake(discountLine.frame.origin.x, discountLine.frame.origin.y, [CommonUtils sizeWithText:priceName.text withFont:priceName.font size:CGSizeMake(CGFLOAT_MAX, priceName.frame.size.height)].size.width, 1);
                
                UILabel *saleNumName = (UILabel*)[cell viewWithTag:12];
                saleNumName.text = [NSString stringWithFormat:@"%@件", [backDataArray valueForKey:@"sale_count"]];
                
                // pointNum
                NSString *pointNamePrefix = @"您购买本件商品可获得";
                NSString *pointNum = [backDataArray valueForKey:@"earn_point"];
                NSString *pointNameSuffix = @"积分! 赶快下手吧!";
                
                UILabel *saleDesc = [[UILabel alloc] initWithFrame:CGRectMake(16, 37, SCREEN_WIDTH-32, 21)];
                
                if (pointNum != nil) {
                    saleDesc.textColor = HEX_COLOR(@"0x999999");
                    saleDesc.font = [UIFont systemFontOfSize:13.f];
                    
                    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@", pointNamePrefix, pointNum, pointNameSuffix]];
                    
                    [attributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:17.f]
                                          range:NSMakeRange(pointNamePrefix.length+1, pointNum.length)];
                    [attributedStr addAttribute:NSForegroundColorAttributeName
                                          value:HEX_COLOR(@"0xf86052")
                                          range:NSMakeRange(pointNamePrefix.length+1, pointNum.length)];
                    saleDesc.attributedText = attributedStr;
                    
                    [cell.contentView addSubview:saleDesc];
                }
                
                if (![pointNum isEqualToString:@"0"]) {
                    saleDesc.hidden = NO;
                } else {
                    saleDesc.hidden = YES;
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
            break;
            
        case 1:
        {
            int showH = 0;
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductSKUView" owner:self options:nil] lastObject];
            
            UILabel *specNote = (UILabel*)[cell viewWithTag:10];
            
            NSString *specStr1 = [backDataArray valueForKey:@"spec2_text"];
            UILabel *specName1 = (UILabel*)[cell viewWithTag:11];
            specName1.text = specStr1;
            
            NSString *specStr2 = [backDataArray valueForKey:@"spec1_text"];
            UILabel *specName2 = (UILabel*)[cell viewWithTag:12];
            specName2.text = specStr2;
            
            NSDictionary *skuDict = [[backDataArray valueForKey:@"skus"] valueForKey:@"lists"];
            
            NSArray* sizeArray = [skuDict valueForKey:@"size_and_stock"];
            
            sizeCount = [sizeArray count];
            
            UIButton *butSize = (UIButton *)[cell viewWithTag:SKU_SIZE_TAG];
            
            if (specStr1.length > 0 && sizeCount > 0) {
                
                showH += 75;
                
                // size
                int sizeNameWidth = [CommonUtils sizeWithText:self.skuSize withFont:[UIFont systemFontOfSize:14.f] size:CGSizeMake(MAXFLOAT, 28)].size.width;
                
                butSize.frame = CGRectMake(71, 44, sizeNameWidth+5, 28);
                [butSize setTitle:self.skuSize forState:UIControlStateNormal];
                [butSize setTitleColor:HEX_COLOR(@"0x777777") forState:UIControlStateNormal];
                [butSize setFont:[UIFont systemFontOfSize:14.f]];
                butSize.layer.borderColor = HEX_COLOR(@"0xb7b7b7").CGColor;
                butSize.layer.borderWidth = 0.5;
                
                butSize.hidden = NO;
            } else {
                butSize.hidden = YES;
            }
            
            // 根据返回的图片数组来显示颜色图片的个数
            NSArray* colorArray = [skuDict valueForKey:@"thumbnail_urls"];
            int colorCount = [colorArray count];
            
            int colorLine = colorCount / 5;
            if (colorCount % 5 != 0) {
                colorLine ++;
            }
            
            if (specStr2.length > 0 && colorCount > 0) {
                
                showH += (45 * colorLine + 10);
                
                for (int i = 0; i < colorCount;  i++) {
                    UIButton *colorImgBut = [[UIButton alloc] initWithFrame:CGRectMake(71 + (i%5*50), 78 + (i/5)*50, 38, 38)];
                    
                    NSString *imageURL = [NSString stringWithFormat:@"%@", colorArray[i][0]];
                    
                    [colorImgBut sd_setBackgroundImageWithURL:[NSURL URLWithString:imageURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        //Nothing.
                    }];
                    
                    colorImgBut.tag = BORDERTAG+i;
                    [colorImgBut addTarget:self
                                    action:@selector(changeSize:)
                          forControlEvents:UIControlEventTouchUpInside];
                    
                    if (colorImgBut.tag == BORDERTAG) {
                        colorImgBut.layer.borderColor = [[UIColor redColor] CGColor];
                        colorImgBut.layer.borderWidth = 0.5;
                    }
                    
                    [cell addSubview:colorImgBut];
                }
            }
            
            // Store
            UITableViewCell *storeCell = [[[NSBundle mainBundle] loadNibNamed:@"ProductStoreView" owner:self options:nil] lastObject];
            
            storeCell.contentView.frame = CGRectMake(0, showH, SCREEN_WIDTH, 55);
            UITextField *addCount = (UITextField *)[self.view viewWithTag:PAY_NUMBER_TAG];
            
            addCount.layer.borderColor = HEX_COLOR(@"0xb7b7b7").CGColor;
            addCount.layer.borderWidth = 0.5;
            
            UILabel *stockName = (UILabel *)[storeCell viewWithTag:STORE_NUMBER_TAG];
            int stockNumber = [[[skuDict valueForKey:@"sku_total_stock"][0] valueForKey:@"count"][0] intValue];
            stockName.text = [NSString stringWithFormat:@"库存(%d)件", stockNumber];
            
            UIButton *btnBuynow = (UIButton *)[self.view viewWithTag:PAY_BTN_TAG];
            UIButton *btnAddToCart = (UIButton *)[self.view viewWithTag:CART_BTN_TAG];
            
            if (stockNumber < 1) {
                
                btnBuynow.enabled = NO;
                btnBuynow.backgroundColor = [UIColor grayColor];
                
                btnAddToCart.enabled = NO;
                btnAddToCart.backgroundColor = [UIColor grayColor];
            } else {
                
                btnBuynow.enabled = YES;
                btnBuynow.backgroundColor = HEX_COLOR(@"0xf86052");
                
                btnAddToCart.enabled = YES;
                btnAddToCart.backgroundColor = HEX_COLOR(@"0x4fa3e1");
            }
            
            UIView *btnBgView = (UIView *)[storeCell viewWithTag:10];
            btnBgView.layer.borderColor = HEX_COLOR(@"0xb7b7b7").CGColor;
            btnBgView.layer.borderWidth = 0.5;
            
            UIButton *btnSub = (UIButton *)[storeCell viewWithTag:11];
            [btnSub addTarget:self action:@selector(doSubCount:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *btnAdd = (UIButton *)[storeCell viewWithTag:12];
            [btnAdd addTarget:self action:@selector(doAddCount:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:storeCell.contentView];
            
            if (showH > 0) {
                specNote.hidden = NO;
            } else {
                specNote.hidden = YES;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        }
            break;
            
        case 2:
        {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductActionView" owner:self options:nil] lastObject];
            
            UIButton *btnBuynow = (UIButton *)[cell viewWithTag:PAY_BTN_TAG];
            btnBuynow.layer.cornerRadius=2;
            [btnBuynow.layer setMasksToBounds:YES];
            [btnBuynow addTarget:self action:@selector(doBuyLogic:) forControlEvents:UIControlEventTouchUpInside];
            
            // AddToCart
            UIButton *btnAddToCart = (UIButton *)[cell viewWithTag:CART_BTN_TAG];
            btnAddToCart.layer.cornerRadius=2;
            [btnAddToCart.layer setMasksToBounds:YES];
            [btnAddToCart addTarget:self  action:@selector(doAddToCartAnimal:) forControlEvents:UIControlEventTouchUpInside];
            
            // ImmediatelyCollect
            UIButton *btnImmediatelyCollect = (UIButton *)[cell viewWithTag:FAVORITE_BTN_TAG];
            btnImmediatelyCollect.layer.cornerRadius=2;
            [btnImmediatelyCollect.layer setMasksToBounds:YES];
            [btnImmediatelyCollect addTarget:self action:@selector(doAddFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            // BookingExperience
            UIButton *btnBookingExperience = (UIButton *)[cell viewWithTag:EXPERIENCE_BTN_TAG];
            btnBookingExperience.layer.cornerRadius=2;
            [btnBookingExperience.layer setMasksToBounds:YES];
            [btnBookingExperience addTarget:self action:@selector(doAddExperienceAnimal:) forControlEvents:UIControlEventTouchUpInside];
            
            int canShowExperienceVal = [[backDataArray valueForKey:@"practice_flag"] intValue];
            if (canShowExperienceVal != 1) {
                btnBookingExperience.enabled = NO;
                btnBookingExperience.backgroundColor = [UIColor grayColor];
            } else {
                btnBookingExperience.enabled = YES;
                btnBookingExperience.backgroundColor = HEX_COLOR(@"0x63b201");
            }
            
            NSString *imageURL = [NSString stringWithFormat:@"%@",[[[backDataArray valueForKey:@"skus"] valueForKey:@"lists"] valueForKey:@"thumbnail_urls"][0][0]];
            //把地址放入url里面
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageURL]];
            //发送地址请求
            NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
            
            //拿到图片并显示
            NSData *imgData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            UIImage *img=nil;
            img = [UIImage imageWithData:imgData];
            [selectButImg setBackgroundImage:img forState:UIControlStateNormal];
            selectButImg.tag = 30001;
            selectButImg.hidden = YES;
            [selectButExpImg setBackgroundImage:img forState:UIControlStateNormal];
            selectButExpImg.tag = 30002;
            selectButExpImg.hidden = YES;
            NSLog(@"%@----------",backDataArray);
            
            [cell addSubview:selectButImg];
            [cell addSubview:selectButExpImg];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
            break;
            
        case 3:
        {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductDetail" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
            
        case 4:
        {
            UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductComment" owner:self options:nil] lastObject];
            UILabel *commentName = (UILabel*)[cell viewWithTag:10];
            
            commentName.text = [NSString stringWithFormat:@"(%@)",[backDataArray valueForKey:@"comment_count"]];
            [commentName sizeToFit];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        }
            break;
            
        case 5:
        {
            NSLog(@"%@",backCommentArray[0]);
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
            
            NSString *nameStr = [[backCommentArray[indexPath.row] valueForKey:@"creator"] valueForKey:@"nick_name"];
            if (![nameStr isEqualToString:@""]) {
                name.text = nameStr;
            } else {
                name.text = @"游客";
            }
            
            content.text = [backCommentArray[indexPath.row] valueForKey:@"content"];
            time.text = [backCommentArray[indexPath.row] valueForKey:@"comment_date"];
            NSString *imageUrl = [[backCommentArray[indexPath.row] valueForKey:@"creator"] valueForKey:@"thumbnail_url"];
            
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
            
            if (indexPath.row != 0) {

                UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
                [splitView setBackgroundColor:HEX_COLOR(@"0xd3d3d3")];
                [cell.contentView addSubview:splitView];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        }
            break;
            
        default:
            break;
    }
    
    return  nil;
}

#pragma mark - 点击立即购买跳转页面
- (void)doBuyLogicMethod:(UIButton *)sender
{
    if (![self isLogined]) {
        return;
    }
    
    addCartState = 0;
    [self doAddToCartLogic:@"0"];
}

- (void)doBuyLogic:(UIButton *)sender
{
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doBuyLogicMethod:) object:sender];
    [self performSelector:@selector(doBuyLogicMethod:) withObject:sender afterDelay:0.2f];
}

#pragma mark - 添加商品评论
- (void)createComment
{
    if (![self isLogined]) {
        
        return;
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    [dataDict setObject:@(goodsCommentsImgNumber) forKey:@"score"];
    [dataDict setObject:productContentsText.text forKey:@"content"];
    
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
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         //                                         [self.navigationController popViewControllerAnimated:YES];
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if ([backDic valueForKey:@"data"]!=NULL) {
                                         
                                         [self dismissView];
                                         [self loadCommentData];
                                     } else {
                                         NSLog(@"评论失败");
                                     }
                                 }
                             }];
         
         if (completionBlock) {
             completionBlock();
         }
     }];
    
}

#pragma mark - 立即收藏
- (void)doAddFavoriteMethod:(UIButton *)sender
{
    if (![self isLogined]) {
        
        return;
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    [dataDict setObject:[[[backDataArray valueForKey:@"skus"] valueForKey:@"lists"] valueForKey:@"sku_id"][0] forKey:@"sku_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_member_addfavorites"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString*requestStr) {
                                 
                                 if ([requestStr isEqualToString:@"Start"]) {
                                     
                                     DLog(@"Start");
                                 } else if([requestStr isEqualToString:@"Failed"]) {
                                     
                                     DLog(@"Failed");
                                     
                                     [self showHUDWithText:@"联网失败" completion:^{
                                         //                                         [self.navigationController popViewControllerAnimated:YES];
                                     }];
                                     
                                 } else {
                                     
                                     NSDictionary* backDic = [HttpRequestData jsonValue:requestStr];
                                     NSLog(@"requestStr = %@", backDic);
                                     
                                     if ([backDic valueForKey:@"data"] != NULL) {
                                         [self showHUDWithText:@"收藏成功!"];
                                     } else {
                                         [self showHUDWithText:@"收藏失败!"];
                                     }
                                 }
                             }];
         
         if (completionBlock) {
             completionBlock();
         }
     }];
    
}

- (void)doAddFavorite:(UIButton *)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doAddFavoriteMethod:) object:sender];
    [self performSelector:@selector(doAddFavoriteMethod:) withObject:sender afterDelay:0.2f];
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
                                         
                                         int total = [[[backDic valueForKey:@"data"] objectForKey:@"total"] intValue];
                                         
                                         if (total > 0) {
                                             
//                                             if (backCommentArray && [backCommentArray count] > 0) {
//                                                 
//                                                 [backCommentArray removeAllObjects];
//                                             }
                                             
                                             NSMutableArray *commentDataArray =[[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                             if ([[backDataArray valueForKey:@"comment_count"] isEqualToString:@"1"]) {
                                                 backCommentArray = commentDataArray[0];
                                                 
                                             } else {
                                                 backCommentArray = commentDataArray;
                                             }
                                         }
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark - 显示商品的内容
- (void) loadProductData
{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:productId forKey:@"product_id"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_getproductdetail"
                                                      dataDict:dataDict];
    
    [self showHUDWithText:@"正在加载"
                   inView:self.view
              methodBlock:^(CompletionBlock completionBlock, ATMHud *hud)
     {
         
         [HttpRequestData dataWithDic:paramDict
                          requestType:POST_METHOD
                            serverUrl:HOST_URL
                             andBlock:^(NSString*requestStr) {
                                 
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
                                     
                                     if (backDataArray && [backDataArray count] > 0) {

                                         [backDataArray removeAllObjects];
                                     }
                                     
                                     backDataArray = [backDic valueForKey:@"data"];
                                     
                                     NSDictionary *skuDict = [[backDataArray valueForKey:@"skus"] valueForKey:@"lists"];
                                     if (skuDict && skuDict.count > 0) {
                                         // 赋值
                                         self.skuId = [skuDict valueForKey:@"sku_id"][0];
                                         self.skuSize = [[skuDict valueForKey:@"sku_total_stock"][0] valueForKey:@"size"][0];
                                         self.skuQty = @"1";
                                     }
                                     
                                     self.memberPriceMsg = [backDataArray valueForKey:@"member_sku_product_price"];
                                     
                                     NSArray *imageArr = [skuDict valueForKey:@"thumbnail_urls"][0];
                                     
//                                     dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                         [self initTableHeader:imageArr];
                                         [self initTableFooter];
//                                     });
                                     
                                     [self.mTableView reloadData];
                                     
                                     if (self.noNetWorkView.superview) {
                                         [self.noNetWorkView removeFromSuperview];
                                         
                                         mTableView.alpha = 1;
                                     }
                                 }
                                 
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
     }];
}

#pragma mark - Product Desc Height
- (CGFloat) getProductDescHeight
{
    NSString *productName = [backDataArray valueForKey:@"product_name"];
    NSString *slogan = [backDataArray valueForKey:@"slogan"];
    
    CGRect productRect =[CommonUtils sizeWithText:[NSString stringWithFormat:@"%@ %@", productName, slogan] withFont:[UIFont systemFontOfSize:15.f] size:CGSizeMake(SCREEN_WIDTH-22, MAXFLOAT)];
    DLog(@"productRect is %@", NSStringFromCGRect(productRect));
    
    return productRect.size.height + 26;
}

- (CGFloat)getContentHeight:(NSIndexPath *)indexPath
{
    return [CommonUtils sizeWithText:[backCommentArray[indexPath.row] valueForKey:@"content"] withFont:[UIFont systemFontOfSize:15] size:CGSizeMake(270, CGFLOAT_MAX)].size.height;
}

#pragma mark - do share
- (void)doShare
{

    /*
    [WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"demo 2.0"];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = @"文本内容";
    req.bText = YES;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    */
    
    [self showTimeAlert:@"" message:@"分享"];
}

- (IBAction)goCart:(id)sender
{

    int tag = ((UIButton *)sender).tag;
    
    switch (tag) {
        case FLOAT_CART_BTN_TAG:
        {
            ShoppingCartViewController *shoppingCartVC = [[ShoppingCartViewController alloc] init];
            [self.navigationController pushViewController:shoppingCartVC animated:YES];
        }
            break;

        case FLOAT_EXPERIENCE_BTN_TAG:
        {
            ExperienceViewController *experienceCartVC = [[ExperienceViewController alloc] init];
            [self.navigationController pushViewController:experienceCartVC animated:YES];
        }
            break;

            
        default:
            break;
    }
}

- (BOOL)isLogined
{

    if ([@"" isEqualToString:[AppManager instance].userId]) {
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return NO;
    }
    
    return YES;
}

- (void)openBigImage:(id)sender
{
    DLog(@"openBigImage");
    
    int currentPage = pageControl.currentPage;
    popPageControl.currentPage = currentPage;
    [popScrollView setContentOffset:CGPointMake(currentPage * SCREEN_WIDTH, 0)];
    
    if (!isShow) {
        
        [APP_DELEGATE.window addSubview:windowBgView];
        [APP_DELEGATE.window addSubview:windowPopView];
        isShow = YES;
        
    } else {
        
        [windowPopView removeFromSuperview];
        [windowBgView removeFromSuperview];
        isShow = NO;
    }
}

@end
