//
//  GZHomeViewController.m
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "DHHomeViewController.h"
#import "BigSizeButton.h"
#import "UIButton+LiEnlarged.h"
#import "BigView.h"
#import "DHCommunityViewController.h"
#import "DHTool.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"

#define kSCREEN_WIDTH     [[UIScreen mainScreen] bounds].size.width
#define kSCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height
@interface DHHomeViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) BigView *bottomView;
@property (nonatomic, strong) BigView *testBottomView;
@property (nonatomic, strong) BigView *testBottomView1;

@property (nonatomic,strong)WKWebView *webView;

@end

@implementation DHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createHitTestView];
//    [self createWKWebView];
    [self leftNavBtn];
}
-(void)viewWillLayoutSubviews{
    NSLog(@"1---%.2f",self.testBottomView.frame.size.height);
    NSLog(@"1获取 %@",self.testBottomView.mas_bottom);
}
-(void)viewDidLayoutSubviews{
    NSLog(@"2---%.2f",self.testBottomView.frame.size.height);
    NSLog(@"2获取 %@",self.testBottomView.mas_bottom);

}

- (void)createHitTestView{
    self.bottomView = [[BigView alloc] init];
    self.bottomView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.bottomView];
    
    self.testBottomView = [[BigView alloc] init];
    self.testBottomView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.testBottomView];
    [self.testBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
//        make.bottom.equalTo(self.view).width.offset(-10);
//        make.left.equalTo(self.view).offset(10);
//        make.right.equalTo(self.view).offset(-10);
//        make.top.equalTo(self.view).offset(-10);
    }];
    
    self.testBottomView1 = [[BigView alloc] init];
    self.testBottomView1.backgroundColor = [UIColor greenColor];
    [self.testBottomView addSubview:self.testBottomView1];
    [self.testBottomView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.testBottomView).offset(-10);
        make.left.equalTo(self.testBottomView).offset(10);
        make.right.equalTo(self.testBottomView).offset(-10);
        make.height.offset(100);
    }];
    
    BigSizeButton *btn = [[BigSizeButton alloc] init];
    btn.frame = CGRectMake(0,
                           60,
                           50,
                           50);
    self.bottomView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 88);
    self.bottomView.redButton = btn;
    [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [self.bottomView addSubview:btn];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
       CGFloat topPadding = window.safeAreaInsets.top;
       CGFloat bottomPadding = window.safeAreaInsets.bottom;
    
    
    
}
- (void)leftNavBtn{
    UIButton*leftbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftbutton setTitle:@"点击" forState:(UIControlStateNormal)];
    [leftbutton addTarget:self action:@selector(clickAction:)forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem*item = [[UIBarButtonItem alloc]initWithCustomView:leftbutton];

    UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];

    //将宽度设为负值

    spaceItem.width= -20;

    //将两个BarButtonItem都返回给NavigationItem

    self.navigationItem.leftBarButtonItems=@[spaceItem ,item];
}
- (void)createWKWebView{
    
    //初始化
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKProcessPool *wkprocessPool = [[WKProcessPool alloc] init];
    
    WKUserScript *script = [[WKUserScript alloc] initWithSource:@"window._dswk=true;"
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    configuration.processPool = wkprocessPool;
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) configuration:configuration];
    // UI代理
    _webView.UIDelegate = self;
    // 导航代理
    _webView.navigationDelegate = self;
    // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
    _webView.allowsBackForwardNavigationGestures = YES;
    //可返回的页面列表, 存储已打开过的网页
//    WKBackForwardList * backForwardList = [_webView backForwardList];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.chinadaily.com.cn"]];
////    [request addValue:[self readCurrentCookieWithDomain:@"http://www.chinadaily.com.cn"] forHTTPHeaderField:@"Cookie"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/ChenYilong/CYLTabBarController"]]];
    //页面后退
    [_webView goBack];
    //页面前进
    [_webView goForward];
    //刷新当前页面
    [_webView reload];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"自适应两栏布局.html" ofType:nil];
//    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//  //加载本地html文件
//    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    [self.view addSubview:_webView];
}

- (void)clickAction:(UIButton *)sender{
    sender.selected =! sender.selected;
    if (sender.selected == 1) {
        [self _hideTabbar:^(BOOL i) {
            NSLog(@"-----");
        }];
    }else{
        [self _showTabbar:^(BOOL i) {
            NSLog(@"-----");
        }];
    }
    NSLog(@"点击--%i",sender.selected);
    self.hidesBottomBarWhenPushed = YES;

//    [self.testBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(10, 10, (-self.testBottomView.frame.size.height), 10));
//    }];
    
//    self.tabBarController.tabBar.hidden = YES;
//    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    window.rootViewController.tabBarController.tabBar.hidden = YES;
    
//    [UIApplication sharedApplication].keyWindow.rootViewController.tabBarController.tabBar.hidden = YES;
//    [self hideTabBar];
    [[DHTool sharedInstance] getCurrentVC];
//    [self hideTabBar:self.tabBarController];

//    [self hideTabBar:[UIApplication sharedApplication].keyWindow.rootViewController.tabBarController];
    
}
- (void)_hideTabbar:(void (^)(BOOL))completionHandler {
    UIViewController *rootViewController = [[DHTool sharedInstance] getCurrentVC];
    if (!rootViewController.tabBarController.tabBar.isHidden) {
        rootViewController.tabBarController.tabBar.hidden = YES;
        rootViewController.view.frame = CGRectMake(rootViewController.view.frame.origin.x, rootViewController.view.frame.origin.y, rootViewController.view.frame.size.width, rootViewController.view.frame.size.height + 88);
    }
}


- (void)_showTabbar:(void (^)(BOOL))completionHandler {
    UIViewController *rootViewController = [[DHTool sharedInstance] getCurrentVC];
    if (rootViewController.tabBarController.tabBar.isHidden) {
    rootViewController.tabBarController.tabBar.hidden = NO;
        rootViewController.view.frame = CGRectMake(rootViewController.view.frame.origin.x, rootViewController.view.frame.origin.y, rootViewController.view.frame.size.width, rootViewController.view.frame.size.height - 88);
    }
}

- (void) hideTabBar:(UITabBarController *) tabbarcontroller {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, kSCREEN_HEIGHT, view.frame.size.width, view.frame.size.height+100)];
        }
        else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, kSCREEN_HEIGHT-100)];
        }
    }
    [UIView commitAnimations];
}
- (UIWindow *)getrootVC{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
//    UIViewController *currentVC;
//    if ([rootVC presentedViewController]) {
//        // 视图是被presented出来的
//        rootVC = [rootVC presentedViewController];
//    }
//    if ([rootVC isKindOfClass:[UITabBarController class]]) {
//        // 根视图为UITabBarController
//        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
//    }
}

- (void)hideTabBar {
    if ([self getrootVC].rootViewController.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[[self getrootVC].rootViewController.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [[UIApplication sharedApplication].keyWindow.rootViewController.tabBarController.view.subviews objectAtIndex:1];
    else{
        contentView = [[self getrootVC].rootViewController.tabBarController.view.subviews objectAtIndex:0];
        contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + [UIApplication sharedApplication].keyWindow.rootViewController.tabBarController.tabBar.frame.size.height);
        [self getrootVC].rootViewController.tabBarController.tabBar.hidden = YES;
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
