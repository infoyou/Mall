
/*!
 @header BaseNavigationController.h
 @abstract BaseNavi
 @author Adam
 @version 1.00 2014/12/23 Creation
 */

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController {
  
}

- (void)clickType:(NSString*)aKeyWord
       classIdStr:(NSString *)aClassIdStr
     classShowStr:(NSString *)aClassShowStr;

@end
