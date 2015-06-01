
#import "ProductTypeViewController.h"

#define SEARCH_BAR_W    230
#define PRODUCT_TYPE_BG @"0x2a2a2a"

static NSString * const kICSColorsViewControllerCellReuseId = @"kICSColorsViewControllerCellReuseId";


@interface ProductTypeViewController ()
{
    NSArray *backDataArr;
}

@property(nonatomic, assign) NSInteger previousRow;

@end

@implementation ProductTypeViewController

@synthesize mTableView;
@synthesize mSearchBar;
@synthesize mSearchCancelBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initiscrollViewalization
    }
    return self;
}

#pragma mark - Managing the view

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustView];
    [self loadCommentData];
}

- (void)adjustView
{
    self.view.backgroundColor = HEX_COLOR(PRODUCT_TYPE_BG);
//    int searchH = 44;
//    int tableH = SCREEN_HEIGHT-64-searchH;
    
//    mTableView.frame = CGRectMake(0, searchH, SCREEN_WIDTH, tableH);
    mTableView.backgroundColor = HEX_COLOR(PRODUCT_TYPE_BG);
    
//    mSearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, searchH);
    [mSearchBar setBarTintColor:HEX_COLOR(PRODUCT_TYPE_BG)];
    [mSearchBar setBackgroundColor:HEX_COLOR(PRODUCT_TYPE_BG)];
    [mSearchBar setTintColor:HEX_COLOR(@"0x333333")];
    [mSearchBar.layer setBorderWidth:1.0f];
    [mSearchBar.layer setBorderColor:HEX_COLOR(PRODUCT_TYPE_BG).CGColor];
    [mSearchBar.layer setMasksToBounds:YES];
    mSearchBar.delegate = self;
    
    mSearchCancelBtn.backgroundColor = HEX_COLOR(PRODUCT_TYPE_BG);
    mSearchCancelBtn.hidden = YES;
}

#pragma mark - Configuring the view’s layout behavior

- (UIStatusBarStyle)preferredStatusBarStyle
{
    // Even if this view controller hides the status bar, implementing this method is still needed to match the center view controller's
    // status bar style to avoid a flicker when the drawer is dragged and then left to open.
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (backDataArr && backDataArr.count > 0) {

        return backDataArr.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(backDataArr);
    
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductTypeCell" owner:self options:nil] lastObject];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
    UILabel *typeName = (UILabel*)[cell viewWithTag:11];
    UIImageView *accessoryView = (UIImageView *)[cell viewWithTag:12];
    
    NSString *imageUrl = [backDataArr[indexPath.row] valueForKey:@"class_cover_img"];
    [iconView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:imageUrl] andPlaceholderImage:[UIImage imageNamed:@"placehold.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //Nothing.
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //Nothing.
    }];

    typeName.text = [backDataArr[indexPath.row] valueForKey:@"class_name"];
    
    typeName.textColor = HEX_COLOR(@"0xffffff");
    accessoryView.image = [UIImage imageNamed:@"typeUnSel.png"];
    
    cell.backgroundColor = HEX_COLOR(PRODUCT_TYPE_BG);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    // 样式修改
    UITableViewCell * selCell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *typeName = (UILabel*)[selCell viewWithTag:11];
    UIImageView *accessoryView = (UIImageView *)[selCell viewWithTag:12];
    
    typeName.textColor = HEX_COLOR(@"0xd85950");
    accessoryView.image = [UIImage imageNamed:@"typeSeled.png"];
    
    for (int i=0; i<backDataArr.count; i++) {
        
        if (i != row) {
            
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            UITableViewCell * otherCell = [tableView cellForRowAtIndexPath:otherIndexPath];
            UILabel *otherTypeName = (UILabel*)[otherCell viewWithTag:11];
            UIImageView *otherAccessoryView = (UIImageView *)[otherCell viewWithTag:12];
            
            otherTypeName.textColor = HEX_COLOR(@"0xffffff");
            otherAccessoryView.image = [UIImage imageNamed:@"typeUnSel.png"];
        }
    }
    
    // 数据传输
//    if (indexPath.row == self.previousRow) {
//        // Close the drawer without no further actions on the center view controller
//        [self.drawer close];
//    } else {
        // Reload the current center view controller and update its background color
        typeof(self) __weak weakSelf = self;
        [self.drawer reloadCenterViewControllerUsingBlock:^(){
            
            [(BaseNavigationController*)weakSelf.drawer.centerViewController clickType:@"" classIdStr:[backDataArr[indexPath.row] valueForKey:@"class_id"] classShowStr:[backDataArr[indexPath.row] valueForKey:@"class_name"]];
        }];
//    }
    
    self.previousRow = indexPath.row;
}

#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

#pragma mark - 显示商品评论
- (void) loadCommentData
{
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"0" forKey:@"offset"];
    [dataDict setObject:@"100" forKey:@"num"];
    
    NSMutableDictionary *paramDict = [CommonUtils getParamDict:@"wuadian_product_getproductclasslist"
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
                                         
                                         backDataArr = [[backDic valueForKey:@"data"] valueForKey:@"lists"];
                                         NSLog(@"%d",backDataArr.count);
                                         
                                         [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kICSColorsViewControllerCellReuseId];
                                         [self.mTableView reloadData];
                                         self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                     }
                                 }
                             }];
     }];
    
}

#pragma mark - UISearchBarDelegate method

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    mSearchCancelBtn.hidden = NO;
    mSearchBar.frame = CGRectMake(mSearchBar.frame.origin.x, mSearchBar.frame.origin.y, SEARCH_BAR_W - mSearchCancelBtn.frame.size.width, mSearchBar.frame.size.height);
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    if (backDataArr && backDataArr.count > 0) {
        [mTableView reloadData];
    }
    
    [searchBar resignFirstResponder];
    
    // 传输数据
    typeof(self) __weak weakSelf = self;
    [self.drawer reloadCenterViewControllerUsingBlock:^(){
        // Reload list
        [(BaseNavigationController*)weakSelf.drawer.centerViewController clickType:searchBar.text classIdStr:nil classShowStr:@"所有商品"];
    }];
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

- (IBAction)doAllTypeClicked
{

    if (backDataArr && backDataArr.count > 0) {
        [mTableView reloadData];
    }

    // 传输数据
    typeof(self) __weak weakSelf = self;
    [self.drawer reloadCenterViewControllerUsingBlock:^(){
        // Reload list
        [(BaseNavigationController*)weakSelf.drawer.centerViewController clickType:@"" classIdStr:nil classShowStr:@"所有商品"];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
