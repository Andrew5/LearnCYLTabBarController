//
//  DHCenterView.h
//  
//
//  Created by jabraknight on 2021/2/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ReturnBlock)(NSString * _Nonnull showText);

@interface DHCenterView : UIView

@property (nonatomic, copy) ReturnBlock _Nullable returnBlock;

@end

NS_ASSUME_NONNULL_END
