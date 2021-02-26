//
//  GZMineViewController.m
//  wcdb
//
//  Created by jabraknight on 2021/2/24.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "DHMineViewController.h"
#import "DHTestTableViewCell.h"
#import "ArrayDataSource.h"
#import "DHModel.h"

#define DeviceWidth      [[UIScreen mainScreen] bounds].size.width
#define DeviceHeight     [[UIScreen mainScreen] bounds].size.height
@interface DHMineViewController ()<UITableViewDelegate>{
    ArrayDataSource *photosArrayDataSource;
}
@property (nonatomic,strong)UITableView *mainTableView;
@property (nonatomic,strong)NSMutableArray *arrData;
@property (nonatomic,strong)DHModel *model;

@end

@implementation DHMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTable];
    [self dataChuli];
}
/*
将TableView DataSource单独抽出来，让很多ViewController可以共用一个自定义的DataSource
 */
- (void)createTable{
    self.mainTableView = [[UITableView alloc]init];
    self.mainTableView.frame = CGRectMake(0, 0, DeviceWidth, DeviceHeight);
    self.mainTableView.delegate = self;
    [self.mainTableView registerNib:[UINib nibWithNibName:@"DHTestTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DHTestTableViewCell"];
    [self.view addSubview:self.mainTableView];
}
- (void)dataChuli{
    void (^configureCell)(DHTestTableViewCell*, DHModel*) = ^(DHTestTableViewCell* cell, DHModel* model) {
        cell.model = model;
    };
    NSString *cellIndentifier = @"DHTestTableViewCell";
    NSArray *dataArr = [self createCellModels];

    photosArrayDataSource = [[ArrayDataSource alloc]initWithDataArr:dataArr cellIdentifier:cellIndentifier configureCellBlock:configureCell];
//    self.mainTableView.dataSource = photosArrayDataSource;
    [self customTableViewShowStyle];
}
#pragma mark - custom methods
-(NSArray *)createCellModels {
    
    DHModel * nameModel = [[DHModel alloc] init];
    nameModel.nameStr = @"uid";
    nameModel.nameSubStr = @"请输入用户名";
    
    DHModel * pwdModel = [[DHModel alloc] init];
    pwdModel.nameStr = @"pwd";
    pwdModel.nameSubStr = @"请输入登录密码";
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [dataArray addObject:nameModel];
    [dataArray addObject:pwdModel];
    
    for (int i = 0; i<20; i++) {
        _model = [[DHModel alloc]init];
        _model.nameStr = [NSString stringWithFormat:@"我是第%i个名字",i+1];
        _model.nameSubStr = @"麻豆腐";
        [dataArray addObject:_model];
    }
    
    return dataArray;
    
}
#pragma mark - 设置TableView显示样式
-(void)customTableViewShowStyle {
    _mainTableView.dataSource = photosArrayDataSource;
    
    _mainTableView.tableHeaderView = [[UIView alloc] init];
    _mainTableView.tableFooterView = [[UIView alloc] init];
//    _mainTableView.scrollEnabled = YES;
    
    //1.调整(iOS7以上)表格分隔线边距
    if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        _mainTableView.separatorInset = UIEdgeInsetsZero;
    }
    //2.调整(iOS8以上)view边距(或者在cell中设置preservesSuperviewLayoutMargins,二者等效)
    if ([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        _mainTableView.layoutMargins = UIEdgeInsetsZero;
    }
    [_mainTableView reloadData];

}

//-(void)loadPriorities {
//   NSDate* now = [NSDate date];
//   NSString* formatString = @"startDate = %@";
//   NSPredicate* predicate = [NSPredicate predicateWithFormat:formatString, now, now];
//   NSSet* priorities = [self.user.priorities filteredSetUsingPredicate:predicate];
//   self.priorities = [priorities allObjects];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
