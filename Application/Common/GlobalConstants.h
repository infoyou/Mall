//
//  GlobalConstants.h
//  Mall
//
//  Created by Adam on 14-12-1.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "UIDevice+Hardware.h"

enum TRANS_SERVER_TY
{
    
    WUADIAN_GETINDEXCONTENT_TY,
    WUADIAN_GETPRODUCTDETAIL_TY,
};

#define	KEYBOARD_ANIMATION_DURATION   0.3f

// URL
#define HOST_URL                    @"http://bpotest.5adian.com/tiyandian_test/5aframework/src/init/index.php"
#define WEB_URL                     @"http://bpotest.5adian.com/tiyandian_test/5aframework/src/init/webview/proinfo.php"
#define UPLOAD_URL                  @"http://bpotest.5adian.com/tiyandian_test/5AdianV3/uploadimgforandroid.php"

#define GET_METHOD                  @"GET"
#define POST_METHOD                 @"POST"

#define CID_PARAM                   @"IJGASxjqQA" //@"KMKASxjrQQ" // //@"epOASxjrSQ" //
#define USER_PARAM                  @"L8SETw"

#define ORIGINAL_MAX_WIDTH          640.0f
#define kTabBarHeight               45.f

#define OBJ_FROM_DIC(_DIC_, _KEY_) [CommonUtils validateResult:_DIC_ dicKey:_KEY_]
#define STRING_VALUE_FROM_DIC(_DIC_, _KEY_) ((NSString *)OBJ_FROM_DIC(_DIC_, _KEY_) == nil ? @"": (NSString *)OBJ_FROM_DIC(_DIC_, _KEY_))
#define INT_VALUE_FROM_DIC(_DIC_, _KEY_) ((NSString *)OBJ_FROM_DIC(_DIC_, _KEY_)).intValue
#define FLOAT_VALUE_FROM_DIC(_DIC_, _KEY_) ((NSString *)OBJ_FROM_DIC(_DIC_, _KEY_)).floatValue
#define DOUBLE_VALUE_FROM_DIC(_DIC_, _KEY_) ((NSString *)OBJ_FROM_DIC(_DIC_, _KEY_)).doubleValue

#pragma mark - draw UI elements
#define COLOR(r, g, b)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define HEX_COLOR(__STR)          [UIColor colorWithHexString:__STR]
#define TRANSPARENT_COLOR         [UIColor clearColor]

#define NAVI_BAR_BG_COLOR            @"0xf86052"
#define VIEW_BG_COLOR                @"0xeeeeee"


#pragma mark - system info
#define IOS5    5.000000f
#define IOS4    4.000000f
#define IOS6    6.000000f
#define IOS7    7.000000f
#define IOS8    8.000000f
#define IOS4_2  4.2f
#define IPHONE_SIMULATOR			@"iPhone Simulator"

#define CURRENT_OS_VERSION  [[[UIDevice currentDevice] systemVersion] floatValue]


// UI
#pragma mark - Alert
#define ShowAlertWithOneButton(Delegate,TITLE,MSG,But) [[[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:Delegate \
cancelButtonTitle:But \
otherButtonTitles:nil] autorelease] show]

#define ShowAlertWithTwoButton(Delegate,TITLE,MSG,But1,But2) [[[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:Delegate \
cancelButtonTitle:But1 \
otherButtonTitles:But2, nil] autorelease] show]

@interface GlobalConstants : NSObject {
    
}

@end
