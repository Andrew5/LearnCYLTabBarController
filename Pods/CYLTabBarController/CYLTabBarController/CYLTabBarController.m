//
//  CYLTabBarController.m
//  CYLTabBarController
//
//  v1.21.x Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 10/20/15.
//  Copyright © 2018 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLTabBarController.h"
#import "CYLTabBar.h"
#import <objc/runtime.h>
#import "UIViewController+CYLTabBarControllerExtention.h"
#import "UIControl+CYLTabBarControllerExtention.h"
#import "UIImage+CYLTabBarControllerExtention.h"
#if __has_include(<Lottie/Lottie.h>)
#import <Lottie/Lottie.h>
#else
#endif

NSString *const CYLTabBarItemTitle = @"CYLTabBarItemTitle";
NSString *const CYLTabBarItemImage = @"CYLTabBarItemImage";
NSString *const CYLTabBarItemSelectedImage = @"CYLTabBarItemSelectedImage";
NSString *const CYLTabBarItemImageInsets = @"CYLTabBarItemImageInsets";
NSString *const CYLTabBarItemTitlePositionAdjustment = @"CYLTabBarItemTitlePositionAdjustment";
NSString *const CYLTabBarLottieURL = @"CYLTabBarLottieURL";
NSString *const CYLTabBarLottieSize = @"CYLTabBarLottieSize";

NSUInteger CYLTabbarItemsCount = 0;
NSUInteger CYLPlusButtonIndex = 0;
CGFloat CYLTabBarItemWidth = 0.0f;
CGFloat CYLTabBarHeight = 0.0f;

NSString *const CYLTabBarItemWidthDidChangeNotification = @"CYLTabBarItemWidthDidChangeNotification";
static void * const CYLTabImageViewDefaultOffsetContext = (void*)&CYLTabImageViewDefaultOffsetContext;

@interface CYLTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign, getter=isObservingTabImageViewDefaultOffset) BOOL observingTabImageViewDefaultOffset;
@property (nonatomic, assign, getter=shouldInvokeOnceViewDidLayoutSubViewsBlock) BOOL invokeOnceViewDidLayoutSubViewsBlock;
@property (nonatomic, strong) NSMutableArray<NSURL *> *lottieURLs;
@property (nonatomic, strong) NSMutableArray *lottieSizes;
@property (nonatomic, assign, getter=isLottieViewAdded) BOOL lottieViewAdded;
@property (nonatomic, strong) UIImage *tabItemPlaceholderImage;

@end

@implementation CYLTabBarController

@synthesize viewControllers = _viewControllers;

#pragma mark -
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (CYL_IS_IPHONE_X) {
        self.tabBarHeight = 83;
    } 
    // 处理tabBar，使用自定义 tabBar 添加 发布按钮
    [self setUpTabBar];
    // KVO注册监听
    if (!self.isObservingTabImageViewDefaultOffset) {
        [self.tabBar addObserver:self forKeyPath:@"tabImageViewDefaultOffset" options:NSKeyValueObservingOptionNew context:CYLTabImageViewDefaultOffsetContext];
        self.observingTabImageViewDefaultOffset = YES;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self updateSelectionStatusIfNeededForTabBarController:nil shouldSelectViewController:nil];
    UIControl *selectedControl = [self.tabBar cyl_tabBarButtonWithTabIndex:selectedIndex];
    if (selectedControl) {
        [self didSelectControl:selectedControl];
    }
}

- (void)setViewDidLayoutSubViewsBlockInvokeOnce:(BOOL)invokeOnce block:(CYLViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock  {
    self.viewDidLayoutSubviewsBlock = viewDidLayoutSubviewsBlock;
    self.invokeOnceViewDidLayoutSubViewsBlock = YES;
}

- (void)setViewDidLayoutSubViewsBlock:(CYLViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock {
    _viewDidLayoutSubviewsBlock = viewDidLayoutSubviewsBlock;
}

- (void)viewDidLayoutSubviews {
    [self.tabBar layoutSubviews];//Fix issue #93 #392
    CYLTabBar *tabBar =  (CYLTabBar *)self.tabBar;
    // add callback for visiable control, included all plusButton.
    [tabBar.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        //to avoid invoking didSelectControl twice, because plusChildViewControllerButtonClicked will invoke setSelectedIndex
        if ([control cyl_isChildViewControllerPlusButton]) {
            return;
        }
        UILabel *tabLabel = control.cyl_tabLabel;
        tabLabel.textAlignment = NSTextAlignmentCenter;
        SEL actin = @selector(didSelectControl:);
        [control addTarget:self action:actin forControlEvents:UIControlEventTouchUpInside];
        if (idx == self.selectedIndex && ![control isKindOfClass:[CYLPlusButton class]]) {
            control.selected = YES;
        }
    }];

    do {
        if (self.isLottieViewAdded) {
            break;
        }
        //FIXME:
        NSArray *subTabBarButtonsWithoutPlusButton = tabBar.cyl_subTabBarButtonsWithoutPlusButton;
        BOOL isLottieEnabled = [self isLottieEnabled];
        if(!isLottieEnabled || (subTabBarButtonsWithoutPlusButton.count != self.lottieURLs.count)) {
            self.lottieViewAdded = YES;
            break;
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [subTabBarButtonsWithoutPlusButton enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
                UIControl *tabButton = control;
                BOOL defaultSelected = NO;
                if (idx == self.selectedIndex) {
                    defaultSelected = YES;
                }
                [self addLottieImageWithControl:tabButton animation:defaultSelected defaultSelected:defaultSelected];
            }];
            self.lottieViewAdded = YES;
        });
        break;
    } while (NO);
    
    
    if (self.shouldInvokeOnceViewDidLayoutSubViewsBlock) {
        //在对象生命周期内，不添加 flag 属性的情况下，防止多次调进这个方法
        if (objc_getAssociatedObject(self, _cmd)) {
            return;
        } else {
            !self.viewDidLayoutSubviewsBlock ?: self.viewDidLayoutSubviewsBlock(self);
            objc_setAssociatedObject(self, _cmd, @"shouldInvokeOnceViewDidLayoutSubViewsBlock", OBJC_ASSOCIATION_RETAIN);
        }
        return;
    }
    !self.viewDidLayoutSubviewsBlock ?: self.viewDidLayoutSubviewsBlock(self);
}

- (void)viewWillLayoutSubviews {
    if (!(self.tabBarHeight > 0)) {
        return;
    }
    self.tabBar.frame = ({
        CGRect frame = self.tabBar.frame;
        CGFloat tabBarHeight = self.tabBarHeight;
        frame.size.height = tabBarHeight;
        frame.origin.y = self.view.frame.size.height - tabBarHeight;
        frame;
    });
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    _tabBarHeight = tabBarHeight;
    CYLTabBarHeight = tabBarHeight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *controller = self.selectedViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)controller;
        return navigationController.topViewController.supportedInterfaceOrientations;
    } else {
        return controller.supportedInterfaceOrientations;
    }
}

- (void)dealloc {
    UIButton<CYLPlusButtonSubclassing> *plusButton = CYLExternPlusButton;
    if (plusButton.superview && (plusButton.superview == self.tabBar)) {
        plusButton.selected = NO;
        [plusButton removeFromSuperview];
    }
    BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
    BOOL hasPlusChildViewController = [self hasPlusChildViewController] && isAdded;
    if (isAdded && hasPlusChildViewController && CYLPlusChildViewController.cyl_plusViewControllerEverAdded == YES) {
        [CYLPlusChildViewController cyl_setPlusViewControllerEverAdded:NO];
    }
    // KVO反注册
    if (self.isObservingTabImageViewDefaultOffset) {
        @try {
            [self.tabBar removeObserver:self forKeyPath:@"tabImageViewDefaultOffset"];
        } @catch(NSException *e) { }
    }
}

#pragma mark -
#pragma mark - public Methods

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:UIEdgeInsetsZero
                 titlePositionAdjustment:UIOffsetZero
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:imageInsets
                 titlePositionAdjustment:titlePositionAdjustment
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                context:(NSString *)context {
    if (self = [super init]) {
        
        _imageInsets = imageInsets;
        _titlePositionAdjustment = titlePositionAdjustment;
        _tabBarItemsAttributes = tabBarItemsAttributes;
        self.context = context;
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)setContext:(NSString *)context {
    if (context && context.length > 0) {
        _context = [context copy];
    } else {
        _context = NSStringFromClass([CYLTabBarController class]);
    }
    [self.tabBar setValue:_context forKey:@"context"];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                            context:(NSString *)context {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
            context:context];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
                                         context:nil];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self tabBarControllerWithViewControllers:viewControllers
                               tabBarItemsAttributes:tabBarItemsAttributes
                                         imageInsets:UIEdgeInsetsZero
                             titlePositionAdjustment:UIOffsetZero];
}

- (void)hideTabBadgeBackgroundSeparator {
    [self hideTabBarShadowImageView];
}

- (void)hideTabBarShadowImageView {
    [self.tabBar layoutIfNeeded];
    UIImageView *imageView = self.tabBar.cyl_tabShadowImageView;
    imageView.hidden = YES;//iOS13+
    imageView.alpha = 0;
}

+ (BOOL)havePlusButton {
    if (CYLExternPlusButton) {
        return YES;
    }
    return NO;
}

+ (NSUInteger)allItemsInTabBarCount {
    NSUInteger allItemsInTabBar = CYLTabbarItemsCount;
    if ([CYLTabBarController havePlusButton]) {
        allItemsInTabBar += 1;
    }
    return allItemsInTabBar;
}

- (id<UIApplicationDelegate>)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (UIWindow *)rootWindow {
    UIWindow *result = nil;
    do {
        if ([self.appDelegate respondsToSelector:@selector(window)]) {
            result = [self.appDelegate window];
        }
        
        if (result) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  利用 KVC 把系统的 tabBar 类型改为自定义类型。
 */
- (void)setUpTabBar {
    CYLTabBar *tabBar = [[CYLTabBar alloc] init];
    [self setValue:tabBar forKey:@"tabBar"];
    [tabBar cyl_setTabBarController:self];
}

- (BOOL)hasPlusChildViewController {
    NSString *context = CYLPlusChildViewController.cyl_context;
    BOOL isSameContext = [context isEqualToString:self.context] && (context && self.context); // || (!context && !self.context);
    BOOL hasPlusChildViewController = CYLPlusChildViewController && isSameContext;//&& !isAdded;
    return hasPlusChildViewController;
}

- (BOOL)isPlusViewControllerAdded:(NSArray *)viewControllers {
    if ([_viewControllers containsObject:CYLPlusChildViewController]) {
        return YES;
    }
    __block BOOL isAdded = NO;
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isEqualViewController:obj compairedViewController:CYLPlusChildViewController]) {
            isAdded = YES;
            *stop = YES;
            return;
        }
    }];
    return isAdded;;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded;
        if (hasPlusChildViewController) {
            [CYLPlusChildViewController willMoveToParentViewController:nil];
            [CYLPlusChildViewController.view removeFromSuperview];
            [CYLPlusChildViewController removeFromParentViewController];
        }
    }
    
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        if ((!_tabBarItemsAttributes) || (_tabBarItemsAttributes.count != viewControllers.count)) {
            [NSException raise:NSStringFromClass([CYLTabBarController class]) format:@"The count of CYLTabBarControllers is not equal to the count of tabBarItemsAttributes.【Chinese】设置_tabBarItemsAttributes属性时，请确保元素个数与控制器的个数相同，并在方法`-setViewControllers:`之前设置"];
        }
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL addedFlag = [CYLPlusChildViewController cyl_plusViewControllerEverAdded];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded && !addedFlag;
        if (hasPlusChildViewController) {
            NSMutableArray *viewControllersWithPlusButton = [NSMutableArray arrayWithArray:viewControllers];
            [viewControllersWithPlusButton insertObject:CYLPlusChildViewController atIndex:CYLPlusButtonIndex];
            _viewControllers = [viewControllersWithPlusButton copy];
            [CYLPlusChildViewController cyl_setPlusViewControllerEverAdded:YES];
            [CYLExternPlusButton cyl_setTabBarChildViewControllerIndex:CYLPlusButtonIndex];
        } else {
            _viewControllers = [viewControllers copy];
            [CYLExternPlusButton cyl_setTabBarChildViewControllerIndex:NSNotFound];
        }
        CYLTabbarItemsCount = [viewControllers count];
        CYLTabBarItemWidth = ([UIScreen mainScreen].bounds.size.width - CYLPlusButtonWidth) / (CYLTabbarItemsCount);
        NSUInteger idx = 0;
        for (UIViewController *viewController in _viewControllers) {
            NSString *title = nil;
            id normalImageInfo = nil;
            id selectedImageInfo = nil;
            UIOffset titlePositionAdjustment = UIOffsetZero;
            UIEdgeInsets imageInsets = UIEdgeInsetsZero;
            NSURL *lottieURL = nil;
            NSValue *lottieSizeValue = nil;
            if (viewController != CYLPlusChildViewController) {
                title = _tabBarItemsAttributes[idx][CYLTabBarItemTitle];
                normalImageInfo = _tabBarItemsAttributes[idx][CYLTabBarItemImage];
                selectedImageInfo = _tabBarItemsAttributes[idx][CYLTabBarItemSelectedImage];
                lottieURL = _tabBarItemsAttributes[idx][CYLTabBarLottieURL];
                lottieSizeValue = _tabBarItemsAttributes[idx][CYLTabBarLottieSize];

                NSValue *offsetValue = _tabBarItemsAttributes[idx][CYLTabBarItemTitlePositionAdjustment];
                UIOffset offset = [offsetValue UIOffsetValue];
                titlePositionAdjustment = offset;
                
                NSValue *insetsValue = _tabBarItemsAttributes[idx][CYLTabBarItemImageInsets];
                UIEdgeInsets insets = [insetsValue UIEdgeInsetsValue];
                imageInsets = insets;
            } else {
                idx--;
            }
            
            [self addOneChildViewController:viewController
                                  WithTitle:title
                            normalImageInfo:normalImageInfo
                          selectedImageInfo:selectedImageInfo
                    titlePositionAdjustment:titlePositionAdjustment
                                imageInsets:imageInsets
                                  lottieURL:lottieURL
                            lottieSizeValue:lottieSizeValue
             
             ];
            [[viewController cyl_getViewControllerInsteadOfNavigationController] cyl_setTabBarController:self];
            idx++;
        }
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [[viewController cyl_getViewControllerInsteadOfNavigationController] cyl_setTabBarController:nil];
        }
        _viewControllers = nil;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.tabBar setSelectedImageTintColor:tintColor];
#pragma clang diagnostic pop
    }
    self.tabBar.tintColor = tintColor;
}

/**
 *  lazy load tabItemPlaceholderImage
 *
 *  @return UIImage
 */
- (UIImage *)tabItemPlaceholderImage {
    if (_tabItemPlaceholderImage == nil) {
        CGSize placeholderSize = CGSizeMake(22, 22);
        UIImage *placeholderImage = [UIImage cyl_imageWithColor:[UIColor whiteColor] size:placeholderSize];
        UIImage *tabItemPlaceholderImage = placeholderImage;
        _tabItemPlaceholderImage = tabItemPlaceholderImage;
    }
    return _tabItemPlaceholderImage;
}

/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param normalImageInfo   图片
 *  @param selectedImageInfo 选中图片
 */
- (void)addOneChildViewController:(UIViewController *)viewController
                        WithTitle:(NSString *)title
                  normalImageInfo:(id)normalImageInfo
                selectedImageInfo:(id)selectedImageInfo
          titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                      imageInsets:(UIEdgeInsets)imageInsets
                        lottieURL:(NSURL *)lottieURL
                  lottieSizeValue:(NSValue *)lottieSizeValue {
    viewController.tabBarItem.title = title;
    UIImage *normalImage = nil;
    if (normalImageInfo) {
        normalImage = [self getImageFromImageInfo:normalImageInfo];
    } else {
        normalImage = self.tabItemPlaceholderImage;
    }
    viewController.tabBarItem.image = normalImage;

    UIImage *selectedImage = nil;
    if (selectedImageInfo) {
        selectedImage = [self getImageFromImageInfo:selectedImageInfo];
    } else {
        selectedImage = self.tabItemPlaceholderImage;
    }
    viewController.tabBarItem.selectedImage = selectedImage;

    if (self.shouldCustomizeImageInsets || ([self isNOTEmptyForImageInsets:imageInsets])) {
        UIEdgeInsets insets = (([self isNOTEmptyForImageInsets:imageInsets]) ? imageInsets : self.imageInsets);
        viewController.tabBarItem.imageInsets = insets;
    }
    if (self.shouldCustomizeTitlePositionAdjustment || [self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) {
        UIOffset offset = (([self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) ? titlePositionAdjustment : self.titlePositionAdjustment);
        viewController.tabBarItem.titlePositionAdjustment = offset;
    }
    if (lottieURL) {
        [self.lottieURLs addObject:lottieURL];
        NSValue *tureLottieSizeValue = nil;
        do {
            if (!CGSizeEqualToSize(CGSizeZero, [lottieSizeValue CGSizeValue])) {
                tureLottieSizeValue = lottieSizeValue;
                break;
            }
            if (normalImage && !CGSizeEqualToSize(CGSizeZero, normalImage.size)) {
                tureLottieSizeValue = [NSValue valueWithCGSize:normalImage.size];
                break;
            }
            CGSize placeholderSize = CGSizeMake(22, 22);
            tureLottieSizeValue = [NSValue valueWithCGSize:placeholderSize];
            break;
        } while (NO);
        [self.lottieSizes addObject:tureLottieSizeValue];
    }
    [self addChildViewController:viewController];
}

- (UIImage *)getImageFromImageInfo:(id)imageInfo {
    UIImage *image = nil;
    if ([imageInfo isKindOfClass:[NSString class]]) {
        image = [UIImage imageNamed:imageInfo];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([imageInfo isKindOfClass:[UIImage class]]) {
        image = (UIImage *)imageInfo;
    }
    return image;
}

- (BOOL)shouldCustomizeImageInsets {
    BOOL shouldCustomizeImageInsets = [self isNOTEmptyForImageInsets:self.imageInsets];
    return shouldCustomizeImageInsets;
}

- (BOOL)shouldCustomizeTitlePositionAdjustment {
    BOOL shouldCustomizeTitlePositionAdjustment = [self isNOTEmptyForTitlePositionAdjustment:self.titlePositionAdjustment];
    return shouldCustomizeTitlePositionAdjustment;
}

- (BOOL)isNOTEmptyForImageInsets:(UIEdgeInsets)imageInsets {
    if (imageInsets.top != 0 || imageInsets.left != 0 || imageInsets.bottom != 0 || imageInsets.right != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isNOTEmptyForTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    if (titlePositionAdjustment.horizontal != 0 || titlePositionAdjustment.vertical != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isNOTEmptyForSize:(UIOffset)titlePositionAdjustment {
    if (titlePositionAdjustment.horizontal != 0 || titlePositionAdjustment.vertical != 0) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - KVO Method

// KVO监听执行
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != CYLTabImageViewDefaultOffsetContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == CYLTabImageViewDefaultOffsetContext) {
        CGFloat tabImageViewDefaultOffset = [change[NSKeyValueChangeNewKey] floatValue];
        [self offsetTabBarTabImageViewToFit:tabImageViewDefaultOffset];
    }
}

- (void)offsetTabBarTabImageViewToFit:(CGFloat)tabImageViewDefaultOffset {
    if (self.shouldCustomizeImageInsets) {
        return;
    }
    NSArray<UITabBarItem *> *tabBarItems = self.tabBar.items;
    [tabBarItems enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIEdgeInsets imageInset = UIEdgeInsetsMake(tabImageViewDefaultOffset, 0, -tabImageViewDefaultOffset, 0);
        obj.imageInsets = imageInset;
        if (!self.shouldCustomizeTitlePositionAdjustment) {
            obj.titlePositionAdjustment = UIOffsetMake(0, MAXFLOAT);
        }
    }];
}

#pragma mark - delegate
- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController shouldSelect:YES];
}

- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController shouldSelect:(BOOL)shouldSelect {
    [[viewController.tabBarItem cyl_tabButton] cyl_setShouldNotSelect:!shouldSelect];
    if (!shouldSelect) {
        return;
    }
    UIButton *plusButton = CYLExternPlusButton;
    if (!viewController) {
        viewController = self.selectedViewController;
    }
    BOOL isCurrentViewController = [self isEqualViewController:viewController compairedViewController:CYLPlusChildViewController];
    BOOL shouldConfigureSelectionStatus = (!isCurrentViewController);
    plusButton.selected = !shouldConfigureSelectionStatus;
    if (!shouldConfigureSelectionStatus) {
        [self.tabBar cyl_stopAnimationOfAllLottieView];
    }
}

- (BOOL)isEqualViewController:(UIViewController *)viewController compairedViewController:(UIViewController *)compairedViewController {
    if ([viewController isEqual:compairedViewController]) {
        return YES;
    }
    if ([[viewController cyl_getViewControllerInsteadOfNavigationController] isEqual:[compairedViewController cyl_getViewControllerInsteadOfNavigationController]]) {
        return YES;
    }
    return NO;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control {
}

- (BOOL)isLottieEnabled {
    NSInteger lottieURLCount = self.lottieURLs.count;
    BOOL isLottieEnabled = lottieURLCount > 0 ;
    return isLottieEnabled;
}

- (void)didSelectControl:(UIControl *)control {
    SEL actin = @selector(tabBarController:didSelectControl:);

    BOOL shouldSelectViewController =  YES;
    @try {
       shouldSelectViewController = (!control.cyl_shouldNotSelect) && (!control.hidden) ;
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    
    BOOL isSelected = control.cyl_isSelected;
    if (shouldSelectViewController) {
        [self.tabBar.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
        }];
        control.selected = YES;
        UIControl *tabButton = control;
        BOOL isChildViewControllerPlusButton = [control cyl_isChildViewControllerPlusButton];
        BOOL isLottieEnabled = [self isLottieEnabled];
        if (!isSelected && isLottieEnabled && !isChildViewControllerPlusButton) {
            [self addLottieImageWithControl:tabButton animation:YES];
        }
    }
    
    if ([self.delegate respondsToSelector:actin] && shouldSelectViewController) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:actin withObject:self withObject:control ?: self.selectedViewController.tabBarItem.cyl_tabButton];
#pragma clang diagnostic pop
    }
}

- (void)addLottieImageWithControl:(UIControl *)control animation:(BOOL)animation {
    [self addLottieImageWithControl:control animation:animation defaultSelected:NO];
}

- (void)addLottieImageWithControl:(UIControl *)control animation:(BOOL)animation defaultSelected:(BOOL)defaultSelected {
     NSUInteger index = [self.tabBar.cyl_subTabBarButtonsWithoutPlusButton indexOfObject:control];
    if (NSNotFound == index) {
        return;
    }
    if (control.cyl_isPlusButton) {
        return;
    }
    NSURL *lottieURL = self.lottieURLs[index];
    NSValue *lottieSizeValue = self.lottieSizes[index];
    CGSize lottieSize = [lottieSizeValue CGSizeValue];
    [control cyl_addLottieImageWithLottieURL:lottieURL size:lottieSize];
    if (animation) {
        [self.tabBar cyl_animationLottieImageWithSelectedControl:control lottieURL:lottieURL size:lottieSize defaultSelected:defaultSelected];
    }
}

- (id)rootViewController {
    CYLTabBarController *tabBarController = nil;
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    UIViewController *rootViewController = [window.rootViewController cyl_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[CYLTabBarController class]]) {
        tabBarController = (CYLTabBarController *)rootViewController;
    }
    return tabBarController;
}

/**
 *  lazy load lottieURLs
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)lottieURLs {
    if (_lottieURLs == nil) {
        NSMutableArray *lottieURLs = [[NSMutableArray alloc] init];
        _lottieURLs = lottieURLs;
    }
    return _lottieURLs;
}

/**
 *  lazy load lottieSizes
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)lottieSizes {
    if (_lottieSizes == nil) {
        NSMutableArray *lottieSizes = [[NSMutableArray alloc] init];
        _lottieSizes = lottieSizes;
    }
    return _lottieSizes;
}

@end

@implementation NSObject (CYLTabBarControllerReferenceExtension)

- (void)cyl_setTabBarController:(CYLTabBarController *)tabBarController {
    //OBJC_ASSOCIATION_ASSIGN instead of OBJC_ASSOCIATION_RETAIN_NONATOMIC to avoid retain circle
    id __weak weakObject = tabBarController;
    id (^block)(void) = ^{ return weakObject; };
    objc_setAssociatedObject(self, @selector(cyl_tabBarController),
                             block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//TODO: 更新实现，多实例场景下进行栈操作，弹出最新一个。
- (CYLTabBarController *)cyl_tabBarController {
    CYLTabBarController *tabBarController;
    id (^block)(void) = objc_getAssociatedObject(self, @selector(cyl_tabBarController));
    tabBarController = (block ? block() : nil);
    if (tabBarController && [tabBarController isKindOfClass:[CYLTabBarController class]]) {
        return tabBarController;
    }
    if ([self isKindOfClass:[UIViewController class]] && [(UIViewController *)self parentViewController]) {
        tabBarController = [[(UIViewController *)self parentViewController] cyl_tabBarController];
        if ([tabBarController isKindOfClass:[CYLTabBarController class]]) {
            return tabBarController;
        }
    }
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
//    UIWindow *window2 = tabBarController.rootWindow;
//    UIWindow *window3 = [self getCurrectWindow];
//    UIWindow *windows4 = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *rootViewController = [window.rootViewController cyl_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[CYLTabBarController class]]) {
        tabBarController = (CYLTabBarController *)rootViewController;
    }
    return tabBarController;
}
- (UIWindow *)getCurrectWindow{
    if (@available(iOS 13.0, *)) {
        NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene* windowScene = (UIWindowScene*)array[0];
        //如果是普通App开发，可以使用
        //            SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
        //            UIWindow * mainWindow = delegate.window;
        //由于在sdk开发中，引入不了SceneDelegate的头文件，所以需要用kvc获取宿主app的window.
        UIWindow* mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
        if(mainWindow) {
            return mainWindow;
        }else{
            return [UIApplication sharedApplication].windows.lastObject;
        }
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}
/*
+ (UIWindow*)getCurrentWindow {
    if ([[[UIApplication sharedApplication] delegate] window]) {
        return [[[UIApplication sharedApplication] delegate] window];
    }else{
        if(@available(iOS13.0, *)) {
            NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene* windowScene = (UIWindowScene*)array[0];
            //如果是普通App开发，可以使用
//            SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
//            UIWindow * mainWindow = delegate.window;
            //由于在sdk开发中，引入不了SceneDelegate的头文件，所以需要用kvc获取宿主app的window.
            UIWindow* mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
            if(mainWindow) {
                return mainWindow;
            }else{
                return [UIApplication sharedApplication].windows.lastObject;
            }
        }else{
            // Fallback on earlier version
            return [UIApplication sharedApplication].keyWindow;
        }
    }
}
 */
@end
