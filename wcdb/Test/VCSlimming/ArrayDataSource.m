//
//  ArrayDataSource.m
//  wcdb
//
//  Created by jabraknight on 2021/2/25.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "ArrayDataSource.h"
#import "DHTestTableViewCell.h"

@interface ArrayDataSource()
@end
@implementation ArrayDataSource
-  (id)initWithDataArr:(NSArray *)dataArr
      cellIdentifier:(NSString *)aCellIdentifier
  configureCellBlock:(TableViewCellConfigureBlockWithItem)aConfigureCellBlock
 {
     self = [super init];
     if (self) {
         self.dataArr = dataArr;
         self.cellIdentifier = aCellIdentifier;
         self.configureCellBlock = [aConfigureCellBlock copy];
         
     }
     return self;
 }


 - (NSInteger)tableView:(UITableView*)tableView
  numberOfRowsInSection:(NSInteger)section {
     
     return self.dataArr.count;
     
 }

 - (UITableViewCell*)tableView:(UITableView*)tableView
         cellForRowAtIndexPath:(NSIndexPath*)indexPath {
     
     id cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                               forIndexPath:indexPath];
     id item = [self dataArrAtIndexPath:indexPath];
  
     self.configureCellBlock(cell,item);

     return cell;
 }


 - (id)dataArrAtIndexPath:(NSIndexPath *)indexPath
 {
     return self.dataArr[(NSUInteger) indexPath.row];
 }
@end
