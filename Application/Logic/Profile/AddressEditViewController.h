//
//  AddressEditViewController.h
//  Mall
//
//  Created by Adam on 14-12-12.
//  Copyright (c) 2014年 5adian. All rights reserved.
//

#import "RootViewController.h"

@protocol NewAddressDelegate;

@interface AddressEditViewController : RootViewController

@property (nonatomic, assign) id<NewAddressDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIScrollView *bgView;
@property (nonatomic, strong) IBOutlet UITextField *nameTxt;
@property (nonatomic, strong) IBOutlet UITextField *phoneTxt;
@property (nonatomic, strong) IBOutlet UITextField *areaCodeTxt;
@property (nonatomic, strong) IBOutlet UITextField *areaTxt;
@property (nonatomic, strong) IBOutlet UITextView  *addressTxt;

- (void)updateData:(NSString *)aReceiveAddressId
       receiveName:(NSString *)aReceiveName
     receiveMobile:(NSString *)aReceiveMobile
      receiveEmail:(NSString *)aReceiveEmail
    receiveAddress:(NSString *)aReceiveAddress
        locationId:(NSString *)aLocationId
          postCode:(NSString *)aPostCode;

@end

@protocol NewAddressDelegate <NSObject>

@optional

- (void)updateAddressUser:(NSString *)addressUser
             addressPhone:(NSString *)addressPhone
              addressName:(NSString *)addressName;

@end