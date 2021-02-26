//
//  CYLPlusButtonSubclass.m
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "CYLPlusButtonSubclass.h"
#import "DHBottomView.h"
#import "DHCenterView.h"
#import "Masonry.h"
#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

@interface CYLPlusButtonSubclass ()<UIActionSheetDelegate> {
    CGFloat _buttonImageHeight;
    CGPoint _startPoint; //开始触摸坐标

}
///弹窗
@property (nonatomic, strong) DHCenterView *centerView;
///蒙版
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) DHBottomView *bottomView;

@end

@implementation CYLPlusButtonSubclass

  
+ (void)load {
    [super registerSubclass];
}
+ (instancetype)plusButton{
    
    CYLPlusButtonSubclass *composeButton = [[CYLPlusButtonSubclass alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    composeButton.layer.borderColor = [UIColor greenColor].CGColor;
    composeButton.layer.borderWidth = 1.0;
    composeButton.selected = YES;
//    composeButton.layer.cornerRadius = 30;
    //设置背景
//    [composeButton setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button"] forState:UIControlStateNormal];
//    [composeButton setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button_highlighted"] forState:UIControlStateHighlighted];
    
    //设置按钮
    [composeButton setImage:[UIImage imageNamed:@"tabbar_me_icon_normal"] forState:UIControlStateNormal];
    [composeButton setImage:[UIImage imageNamed:@"tabbar_me_icon_selected"] forState:UIControlStateSelected];
    [composeButton addTarget:composeButton action:@selector(clickPublish:) forControlEvents:UIControlEventTouchUpInside];

    return composeButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}
  
//上下结构的 button
- (void)layoutSubviews {
    [super layoutSubviews];
      
    // 控件大小,间距大小
    CGFloat const imageViewEdge   = self.bounds.size.width * 0.7;
    CGFloat const centerOfView    = self.bounds.size.width * 0.5;
    CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
    CGFloat const verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdge;
    CGFloat const verticalMargin  = verticalMarginT / 2;
      
    // imageView 和 titleLabel 中心的 Y 值
    CGFloat const centerOfImageView  = verticalMargin + imageViewEdge * 0.5;
    CGFloat const centerOfTitleLabel = imageViewEdge  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
      
    //imageView position 位置
    self.imageView.bounds = CGRectMake(0, 0, imageViewEdge, imageViewEdge);
    self.imageView.center = CGPointMake(centerOfView, centerOfImageView);
      
    //title position 位置
    self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
    self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
}
  
#pragma mark -
#pragma mark - Public Methods
  
//+ (instancetype)plusButton {
//
//    CYLPlusButtonSubclass *button = [[CYLPlusButtonSubclass alloc] init];
//
//    [button setImage:[UIImage imageNamed:@"tabbar_me_icon_normal"] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"tabbar_me_icon_selected"] forState:UIControlStateSelected];
//
////    [button setTitle:@"发布" forState:UIControlStateNormal];
////    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
////    button.titleLabel.font = [UIFont systemFontOfSize:9.5];
////    [button sizeToFit];
//
//    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
//    return button;
//}
- (void)changeAppIconWithName:(NSString *)iconName {
    if (@available(iOS 10.3, *)) {
        if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    
    if ([iconName isEqualToString:@""]) {
        iconName = nil;
    }
    if (@available(iOS 10.3, *)) {
        [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"更换app图标发生错误了 ： %@",error);
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}
- (void)clickPublish:(UIButton *)sender {
    NSLog(@"点击开始按钮");
    [self changeAppIconWithName:@"App111Icon"];

    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    longGesture.minimumPressDuration = 0.2;
    [sender addGestureRecognizer:longGesture];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissmiss)];
    [self.centerView addGestureRecognizer:tap];
    
    
//    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
//    UIViewController *viewController = tabBarController.selectedViewController;
//
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                             delegate:self
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"拍照", @"从相册选取", @"淘宝一键转卖", nil nil];
//    [actionSheet showInView:viewController.view];
}
- (void)dissmiss{
    self.centerView = nil;
}
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)sender{
    _startPoint = [sender locationInView:self];

    if (self.centerView == nil) {
        self.centerView = [[DHCenterView alloc]init];
        self.centerView.backgroundColor = [UIColor whiteColor];
        self.centerView.layer.cornerRadius = 20;
        self.centerView.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
        [self addSubview:self.centerView];
    }
    
    ///滑动
    if (sender.state == UIGestureRecognizerStateChanged||UIGestureRecognizerStateBegan) {
        self.centerView.frame = CGRectMake(0, _startPoint.y, kViewWidth,kViewHeight - _startPoint.y);
        //        _maskView.alpha = 1-(_startPoint.y/kViewHeight);    }
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (_startPoint.y > kViewHeight/4*3) {
                ///下滑
                [UIView animateWithDuration:0.5 animations:^{
                    self.centerView.frame = CGRectMake(0, kViewHeight+50, kViewWidth,0);
                    [self.centerView layoutIfNeeded];
                    //                ws.maskView.alpha = 0;
                    //                ws.maskView = nil;
                }];
            }else{
                ///上滑
                [UIView animateWithDuration:0.5 animations:^{
                    self.centerView.frame = CGRectMake(0, 200, kViewWidth,kViewHeight - 200);
                    [self.centerView layoutIfNeeded];
                    [self bringSubviewToFront:self.centerView];
                }];
            }
        }
    }
}
  
  
#pragma mark - CYLPlusButtonSubclassing
+ (NSUInteger)indexOfPlusButtonInTabBar {
    return 2;
}
  
+ (CGFloat)multiplerInCenterY {
    return  0.3;
}
// */
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
