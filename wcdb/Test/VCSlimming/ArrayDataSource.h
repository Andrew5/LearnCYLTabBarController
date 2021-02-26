//
//  ArrayDataSource.h
//  wcdb
//
//  Created by jabraknight on 2021/2/25.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^TableViewCellConfigureBlockWithItem)(id cell, id item);//因为要复用，所以要写成id类型
@interface ArrayDataSource : NSObject<UITableViewDataSource>

@property(nonatomic,strong) NSArray  *dataArr;
@property(nonatomic,strong) NSString *cellIdentifier;
@property(nonatomic,copy) TableViewCellConfigureBlockWithItem configureCellBlock;

- (id)initWithDataArr:(NSArray *)dataArr
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlockWithItem)aConfigureCellBlock;

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
