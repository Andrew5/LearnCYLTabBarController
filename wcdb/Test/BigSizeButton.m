//
//  BigSizeButton.m
//  zhundao
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2017年 zhundao. All rights reserved.
//

#import "BigSizeButton.h"

@implementation BigSizeButton
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
////    CGRect bounds = self.bounds;
////        //若原热区小于44x44，则放大热区，否则保持原大小不变
////    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
////    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
////    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
////    return CGRectContainsPoint(bounds, point);
//    
//    CGPoint redBtnPoint = [self convertPoint:point toView:_redButton];
////    if ([_redButton pointInside:redBtnPoint withEvent:event]) {
////        return _redButton;
////    }
//        //如果希望严谨一点，可以将上面if语句及里面代码替换成如下代码
//    UIView *view = [_redButton hitTest: redBtnPoint withEvent: event];
//    if (view) return view;
//    return [super hitTest:point withEvent:event];
//
//    
//    
////    //当前btn大小
////    CGRect btnBounds = self.bounds;
////    //扩大点击区域，想缩小就将-10设为正值
////    btnBounds = CGRectInset(btnBounds, -25, -25);
////    //若点击的点在新的bounds里，就返回YES
////    return CGRectContainsPoint(btnBounds, point);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
