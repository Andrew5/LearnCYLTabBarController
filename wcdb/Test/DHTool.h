#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DHTool : NSObject

//+ (NSString *)getAppKey:(NSString *)appSecret MicroApp:(NSString *)microapp;
+ (DHTool *)sharedInstance;
- (UIView *)topView;
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC;

@end


