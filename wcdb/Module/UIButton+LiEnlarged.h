//
//  UIButton+LiEnlarged.h
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LiEnlarged)
//@property (nonatomic,assign) CGFloat enlargeEdge;
/**
 增大点击区域
 @param size 上左下右的增大量
 */
- (void)be_setEnlargeEdge:(CGFloat)size;

/**
 增大点击区域
 @param size 上左下右的增大量
 */
- (void)be_setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end

NS_ASSUME_NONNULL_END
