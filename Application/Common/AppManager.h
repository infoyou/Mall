
/*!
 @header AppManager.h
 @abstract 系统内存
 @author Adam
 @version 1.00 2014/03/26 Creation
 */

#import <Foundation/Foundation.h>

@interface AppManager : NSObject {
    
}

// User
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userPswd;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *userMobile;
@property (nonatomic, copy) NSString *userPoint;
@property (nonatomic, copy) NSString *userDefaultAddress;
@property (nonatomic, copy) NSString *userProvince;
@property (nonatomic, copy) NSString *userCity;
@property (nonatomic, copy) NSString *userImageUrl;

// Product
@property (nonatomic, copy) NSString *productKeyWord;

@property (nonatomic, retain) NSDictionary *profileCellNumberDict;

+ (AppManager *)instance;

- (void)prepareData;

- (void)rememberUserData:(NSString *)aUserId
                userName:(NSString *)aUserName
                nickName:(NSString *)aNickName
                  avator:(NSString *)avator
                   point:(NSString *)point;

@end
