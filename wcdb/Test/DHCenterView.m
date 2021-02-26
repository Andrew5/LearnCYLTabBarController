//
//  DHCenterView.m
//  
//
//  Created by jabraknight on 2021/2/23.
//

#import "DHCenterView.h"
#import "Masonry.h"

@interface DHCenterView()


@property (nonatomic, strong) UIView *hudView;

@property (strong, nonatomic) UIView *backgroundView; //背景视图

@property (assign, nonatomic) CGFloat startPoint; //
@property (strong, nonatomic) UIImageView *headIconImageView; //


@end

@implementation DHCenterView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupTableView];

    }
    return self;
}
/**
 *  tableView的一些初始化工作
 */
- (void)setupTableView
{
    ///背景动画
    self.backgroundView = [[UIView alloc]init];
    [self addSubview:self.backgroundView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10);
        make.right.equalTo(self).with.offset(-10);
        make.top.equalTo(self).with.offset(10);
        make.bottom.equalTo(self).with.offset(0);

    }];
    
    
    self.headIconImageView = [[UIImageView alloc]init];
    self.headIconImageView.layer.borderColor = [UIColor greenColor].CGColor;
    self.headIconImageView.layer.borderWidth = 1.0;
    self.headIconImageView.layer.cornerRadius = 30;
    self.headIconImageView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.headIconImageView];
    
    [self.headIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backgroundView);
        make.width.height.mas_offset(60);
        make.top.equalTo(self.backgroundView.mas_top).with.offset(-30);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touch = [[touches anyObject] locationInView:self];
    self.startPoint = touch.y;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touch = [[touches anyObject] locationInView:self];
    if ((touch.y - self.startPoint)>10) {
        if (self.returnBlock != nil) {
            self.returnBlock(@"success");
        }
    }
}
- (UIView *)hudView {
    if (_hudView == nil) {
        UIView *hudView = [[UIView alloc]init];
        hudView.frame = [UIApplication sharedApplication].keyWindow.bounds;
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 0, 200, 30);
        CGPoint center = hudView.center;
        center.x = center.x + 50;
        label.center = center;
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor orangeColor];
        label.text = @"加载中。。。";
        hudView.hidden = YES;
        [hudView addSubview:label];
        [[UIApplication sharedApplication].keyWindow addSubview:(_hudView = hudView)];
    }
    return _hudView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
