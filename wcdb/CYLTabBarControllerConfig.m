//
//  CYLTabBarControllerConfig.m
//  CYLTabBarController
//
//  v1.16.0 Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 10/20/15.
//  Copyright © 2015 https://github.com/ChenYilong . All rights reserved.
//
#import "CYLTabBarControllerConfig.h"
#import <UIKit/UIKit.h>

static CGFloat const CYLTabBarControllerHeight = 49.f;

//View Controllers
#import "DHHomeViewController.h"
//#import "DHCommunityViewController.h"
//#import "DHNewsViewController.h"
//#import "DHCenterViewController.h"
#import "DHMineViewController.h"

@interface CYLTabBarControllerConfig ()<UITabBarControllerDelegate>

@property (nonatomic, readwrite, strong) CYLTabBarController *tabBarController;

@end

@implementation CYLTabBarControllerConfig

/**
 *  lazy load tabBarController
 *
 *  @return CYLTabBarController
 */
- (CYLTabBarController *)tabBarController {
    if (_tabBarController == nil) {
        /**
         * 以下两行代码目的在于手动设置让TabBarItem只显示图标，不显示文字，并让图标垂直居中。
         * 等效于在 `-tabBarItemsAttributesForController` 方法中不传 `CYLTabBarItemTitle` 字段。
         * 更推荐后一种做法。
         */
//        UIEdgeInsets imageInsets = UIEdgeInsetsZero;//UIEdgeInsetsMake(4.5, 0, -4.5, 0);
//        UIOffset titlePositionAdjustment = UIOffsetZero;//UIOffsetMake(0, MAXFLOAT);
        CYLTabBarController *tabBarController = [CYLTabBarController tabBarControllerWithViewControllers:self.viewControllers tabBarItemsAttributes:self.tabBarItemsAttributesForController];
        [self customizeTabBarAppearance];
        _tabBarController = tabBarController;
        _tabBarController.delegate = self;
    }
    return _tabBarController;
}

- (NSArray *)viewControllers {
    DHHomeViewController *vc0 = [DHHomeViewController new];
    UINavigationController *nav0 = [[CYLBaseNavigationController alloc] initWithRootViewController:vc0];
        
    DHHomeViewController *vc1 = [DHHomeViewController new];
    UINavigationController *nav1 = [[CYLBaseNavigationController alloc] initWithRootViewController:vc1];
    
    DHHomeViewController *vc2 = [DHHomeViewController new];
    UINavigationController *nav2 = [[CYLBaseNavigationController alloc] initWithRootViewController:vc2];
    
    DHMineViewController *vc3 = [DHMineViewController new];
    UINavigationController *nav3 = [[CYLBaseNavigationController alloc] initWithRootViewController:vc3];

    DHHomeViewController *vc4 = [DHHomeViewController new];
    UINavigationController *nav4 = [[CYLBaseNavigationController alloc] initWithRootViewController:vc4];

    return @[nav0, nav1, nav2, nav3];
}

- (NSArray *)tabBarItemsAttributesForController {

    NSDictionary *dict0 = @{
                            CYLTabBarItemTitle : @"首页",
                            CYLTabBarItemImage : @"tabBar_category_normal",
                            CYLTabBarItemSelectedImage : @"tabBar_category_press",
//                            CYLTabBarLottieURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tab_lottie_0" ofType:@"json"]],
                            };
    NSDictionary *dict1 = @{
                            CYLTabBarItemTitle : @"有了",
                            CYLTabBarItemImage : @"tabBar_home_normal",
                            CYLTabBarItemSelectedImage : @"tabBar_home_press",
//                            CYLTabBarLottieURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tab_lottie_1" ofType:@"json"]],
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemTitle : @"资产",
                            CYLTabBarItemImage : @"tabBar_wealth_normal",
                            CYLTabBarItemSelectedImage : @"tabBar_wealth_press",
//                            CYLTabBarLottieURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tab_lottie_2" ofType:@"json"]],
                            };
    NSDictionary *dict3 = @{
                            CYLTabBarItemTitle : @"我的",
                            CYLTabBarItemImage : @"tabBar_me_normal",
                            CYLTabBarItemSelectedImage : @"tabBar_me_press",
//                            CYLTabBarLottieURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tab_lottie_3" ofType:@"json"]],
                            };
    NSDictionary *dict4 = @{
                            CYLTabBarItemTitle : @"中心",
                            CYLTabBarItemImage : @"tabBar_me_normal",
                            CYLTabBarItemSelectedImage : @"tabBar_me_press",
//                            CYLTabBarLottieURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tab_lottie_4" ofType:@"json"]],
                            };

    NSArray *tabBarItemsAttributes = @[dict0, dict1, dict2, dict3];
    return tabBarItemsAttributes;
}

/**
 *  更多TabBar自定义设置：比如：tabBarItem 的选中和不选中文字和背景图片属性、tabbar 背景图片属性等等
 */
- (void)customizeTabBarAppearance {
        UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    //    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:kUIColorFromRGB(0x303e4a)] forBarMetrics:UIBarMetricsDefault];
        
        navigationBarAppearance.barTintColor = [UIColor redColor];
        navigationBarAppearance.translucent = NO;

    //     可以去除NavBar下面那条线
        if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)]) {
            [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
        }
        //适配iOS11的tableView问题
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        if (@available(iOS 11, *)) {
            [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
        }
        
        // 设置naviegationBar的文本属性
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:18],
                                         NSForegroundColorAttributeName:[UIColor whiteColor],
                                         };
        [navigationBarAppearance setTitleTextAttributes:textAttributes];
        
        // 普通状态下的文字属性
        NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
        normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
        
        // 选中状态下的文字属性
        NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
        selectedAttrs[NSForegroundColorAttributeName] = [UIColor blueColor];
        
        // 设置文字属性
        UITabBarItem *tabBar = [UITabBarItem appearance];
        [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
        [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
        
        // 设置背景图片
        UITabBar *tabBarAppearance = [UITabBar appearance];
        tabBarAppearance.translucent = NO;
        //    [tabBarAppearance setBackgroundImage:[UIImage imageNamed:@"tabbar_background"]];
    //    [[UITabBar appearance] setShadowImage:[UIImage imageWithColor:UIColorHex(f8f8f8)]];
        [[UITabBar appearance] setBarTintColor:[UIColor greenColor]];
}

- (void)updateTabBarCustomizationWhenTabBarItemWidthDidUpdate {
    void (^deviceOrientationDidChangeBlock)(NSNotification *) = ^(NSNotification *notification) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) {
            NSLog(@"Landscape Left or Right !");
        } else if (orientation == UIDeviceOrientationPortrait) {
            NSLog(@"Landscape portrait!");
        }
        [self customizeTabBarSelectionIndicatorImage];
    };
    [[NSNotificationCenter defaultCenter] addObserverForName:CYLTabBarItemWidthDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:deviceOrientationDidChangeBlock];
}

- (void)customizeTabBarSelectionIndicatorImage {
    ///Get initialized TabBar Height if exists, otherwise get Default TabBar Height.
    CGFloat tabBarHeight = CYLTabBarControllerHeight;
    CGSize selectionIndicatorImageSize = CGSizeMake(CYLTabBarItemWidth, tabBarHeight);
    //Get initialized TabBar if exists.
    UITabBar *tabBar = [self cyl_tabBarController].tabBar ?: [UITabBar appearance];
    [tabBar setSelectionIndicatorImage:
     [[self class] imageWithColor:[UIColor yellowColor]
                             size:selectionIndicatorImageSize]];
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width * scaleSize, image.size.height * scaleSize);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width + 1, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
