//
//  UIButton+LiEnlarged.m
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "UIButton+LiEnlarged.h"
#import <objc/runtime.h>
//static char topEdgeKey;
//static char leftEdgeKey;
//static char bottomEdgeKey;
//static char rightEdgeKey;

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;

@implementation UIButton (LiEnlarged)
/*
-(void)setEnlargeEdge:(CGFloat)enlargeEdge
{
    [self setEnlargeEdgeWithTop:enlargeEdge left:enlargeEdge bottom:enlargeEdge right:enlargeEdge];
}
-(void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left
                      bottom:(CGFloat)bottom right:(CGFloat)right
{
    objc_setAssociatedObject(self, &topEdgeKey, [NSNumber numberWithFloat:top], 1);
    objc_setAssociatedObject(self, &leftEdgeKey, [NSNumber numberWithFloat:left], 1);
    objc_setAssociatedObject(self, &bottomEdgeKey, [NSNumber numberWithFloat:bottom], 1);
    objc_setAssociatedObject(self, &rightEdgeKey, [NSNumber numberWithFloat:right], 1);
}
-(CGFloat)enlargeEdge
{
    return [(NSNumber *)objc_getAssociatedObject(self, &topEdgeKey) floatValue];
}
-(CGRect)enlargedRect
{
    NSNumber *topEdge = objc_getAssociatedObject(self, &topEdgeKey);
     NSNumber *leftEdge = objc_getAssociatedObject(self, &leftEdgeKey);
     NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomEdgeKey);
     NSNumber *rightEdge = objc_getAssociatedObject(self, &rightEdgeKey);
    if (topEdge && leftEdge && bottomEdge && rightEdge)
    {
        CGRect enlargeRect = CGRectMake(self.bounds.origin.x - leftEdge.floatValue, self.bounds.origin.y - topEdge.floatValue, self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue, self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
        return enlargeRect;
    }
    
    return self.bounds;
}
//hittest确定点击的对象
 -(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.alpha <= 0.01 || !self.userInteractionEnabled || self.hidden)
    {
        return nil;
    }
    CGRect enlargedRect = [self enlargedRect];
    return CGRectContainsPoint(enlargedRect, point)?self:nil;
    
}
*/

- (void)be_setEnlargeEdge:(CGFloat)size {
    
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)be_setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left {
    
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)be_enlargedRect {
    
    NSNumber *topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    
    if (topEdge && rightEdge && bottomEdge && leftEdge) {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    } else {
        return self.bounds;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect rect = [self be_enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
//
// CGRect rect = [self enlargedRect];
// if (CGRectEqualToRect(rect, self.bounds)) {
//     return [super hitTest:point withEvent:event];
// }
//     return CGRectContainsPoint(rect, point) ? self : nil;
//}


@end
