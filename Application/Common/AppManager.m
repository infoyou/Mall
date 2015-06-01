
#import "AppManager.h"
#import "GlobalConstants.h"
#import "CommonUtils.h"

@implementation AppManager {
}

// User
@synthesize userId;
@synthesize userPswd;
@synthesize userName;
@synthesize userNickName;
@synthesize userEmail;
@synthesize userImageUrl;

@synthesize userMobile;
@synthesize userPoint;
@synthesize userDefaultAddress;
@synthesize userProvince;
@synthesize userCity;

// Product
@synthesize productKeyWord;

@synthesize profileCellNumberDict;

static AppManager *shareInstance = nil;

+ (AppManager *)instance {
    @synchronized(self) {
        if (nil == shareInstance) {
            shareInstance = [[self alloc] init];
        }
    }
    
    return shareInstance;
}

- (void)prepareData
{
    
    [self initUser];
}

- (void)initUser
{
    
    NSString *userIdStr = [self userIdRemembered];
    if (userIdStr != nil && userIdStr.length > 0) {
        
        [AppManager instance].userId = userIdStr;
        [AppManager instance].userName = [self userNameRemembered];
        [AppManager instance].userNickName = [self nickNameRemembered];
        [AppManager instance].userImageUrl = [self avatorRemembered];
        [AppManager instance].userPoint = [self pointRemembered];
    } else {
        
        [AppManager instance].userId = @""; //@"L8SETw";
        [AppManager instance].userName = @"我";
        [AppManager instance].userNickName = @"Adam";
        [AppManager instance].customerName = CID_PARAM;
        [AppManager instance].userImageUrl = @"";
        [AppManager instance].userPoint = @"";
    }
}

- (NSString *) userIdRemembered {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

- (NSString *) userNameRemembered
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

- (NSString *) nickNameRemembered
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
}

- (NSString *) avatorRemembered
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"avator"];
}

- (NSString *) pointRemembered
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"point"];
}

- (void)rememberUserData:(NSString *)aUserId
                userName:(NSString *)aUserName
                nickName:(NSString *)aNickName
                  avator:(NSString *)avator
                   point:(NSString *)aPoint
{
    NSUserDefaults *_def = [NSUserDefaults standardUserDefaults];
    
    if(userId == nil) {
        
        [_def removeObjectForKey:@"userId"];
        [_def removeObjectForKey:@"userName"];
        [_def removeObjectForKey:@"nickName"];
        [_def removeObjectForKey:@"avator"];
        [_def removeObjectForKey:@"point"];
    } else {
        
        [_def setObject:aUserId forKey:@"userId"];
        [_def setObject:aUserName forKey:@"userName"];
        [_def setObject:aNickName forKey:@"nickName"];
        [_def setObject:avator forKey:@"avator"];
        [_def setObject:aPoint forKey:@"point"];
    }
    
    [_def synchronize];
}


@end
