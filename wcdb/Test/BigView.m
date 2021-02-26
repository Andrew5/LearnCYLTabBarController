//
//  BigView.m
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "BigView.h"

@implementation BigView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *tmpView = [super hitTest:point withEvent:event];
    if (tmpView == nil) {
        CGPoint newPoint = [self.redButton convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.redButton.bounds,newPoint)) {
            tmpView = self.redButton;
        }
    }
    return tmpView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
