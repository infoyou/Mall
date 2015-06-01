
#import "SettingViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "ProductDetailViewController.h"
#import "NameEditViewController.h"
#import "PasswordEditViewController.h"


@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) UIImagePickerController *mediaPicker;

@end

@implementation SettingViewController

@synthesize mTableView;
@synthesize mediaPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTableFooter];
    
    self.title = @"设置";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 5;
}

/// 绑定cell的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //    if (cell != nil) {
    //
    //        for (UIView *subView in cell.contentView.subviews)
    //        {
    //            [subView removeFromSuperview];
    //        }
    //    }
    
    if (nil == cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] lastObject];
    }
    
    UILabel *textVal = (UILabel *)[cell viewWithTag:11];
    textVal.text = [[[self getCellTextDictionary] objectForKey:[NSNumber numberWithInt:(indexPath.section + 1) * 100]] objectAtIndex:indexPath.row];
    
//    if (indexPath.row != 0) {
//        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, SCREEN_WIDTH, 1.f)];
//        splitView.backgroundColor = HEX_COLOR(@"0xd3d3d3");
//        [cell.contentView addSubview:splitView];
//    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSMutableDictionary *)getCellTextDictionary
{
    NSMutableArray *cell0TextArray = [[NSMutableArray alloc] initWithObjects:@"修改昵称", @"修改账户密码", @"修改头像", @"关于版本", @"关于我们", nil];
    
    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
    [textDic setObject:cell0TextArray forKey:[NSNumber numberWithInt:100]];
    
    return textDic;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
        {
            // 修改昵称
            NameEditViewController *nameEditVC = [NameEditViewController alloc];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:0 target:nil action:nil];
            nameEditVC.title = @"修改昵称";
            
            [self.navigationController pushViewController:nameEditVC animated:YES];
        }
            break;
        case 1:
        {
            // 修改账户密码
            PasswordEditViewController *pswdEditVC = [PasswordEditViewController alloc];
            self.navigationController.visibleViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:0 target:nil action:nil];
            pswdEditVC.title = @"修改密码";
            
            [self.navigationController pushViewController:pswdEditVC animated:YES];
        }
            break;
        case 2:
        {
            // 修改头像
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                     delegate: self
                                                            cancelButtonTitle: @"取消"
                                                       destructiveButtonTitle: nil
                                                            otherButtonTitles: @"拍照", @"选择相册", nil];
            [actionSheet showInView:self.view];
        }
            break;
        case 3:
        {
            // 关于版本
            [self showHUDWithText:@"Version 1.0"];
        }
            break;
        case 4:
        {
            // 关于我们
            [self showHUDWithText:@"遍享信息技术(上海)有限公司"];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark 初始化uiview 显示商品评论
- (void)initTableFooter
{
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  260)];
    
    UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [splitView setBackgroundColor:HEX_COLOR(@"0xd3d3d3")];
    [footview addSubview:splitView];
    
    UIButton *CommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, 260, 42)];
    [CommentBtn.layer setBorderWidth:1];
    CommentBtn.layer.cornerRadius=4;
    [CommentBtn.layer setMasksToBounds:YES];
    [CommentBtn setBackgroundColor:HEX_COLOR(@"0xf86052")];
    CommentBtn.layer.borderColor = [HEX_COLOR(@"0xf86052") CGColor];
    [CommentBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [CommentBtn addTarget:self action:@selector(doLogout) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:CommentBtn];
    
    self.mTableView.tableFooterView = footview;
}

- (void)doLogout
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认退出？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {

            [AppManager instance].userId = @"";
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
}

- (void)updateAvator
{
    
    mediaPicker = [[UIImagePickerController alloc] init];
    [mediaPicker setDelegate:self];
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"选择相册", nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:mediaPicker animated:YES];
    }
}


#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            
            [self.navigationController presentViewController:controller
                                                    animated:YES
                                                  completion:^(void){
                                                      NSLog(@"Picker View Controller is presented");
                                                  }];
        }
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            
            [self.navigationController presentViewController:controller
                                                    animated:YES
                                                  completion:^(void){
                                                      NSLog(@"Picker View Controller is presented");
                                                  }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - camera utility
- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickVideosFromPhotoLibrary
{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickPhotosFromPhotoLibrary
{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    
    return result;
}

@end
