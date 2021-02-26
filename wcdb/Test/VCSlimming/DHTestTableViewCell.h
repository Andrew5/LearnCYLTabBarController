//
//  DHTestTableViewCell.h
//  wcdb
//
//  Created by jabraknight on 2021/2/25.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DHTestTableViewCell : UITableViewCell
@property (weak,  nonatomic) IBOutlet UILabel *subName;
@property (weak,  nonatomic) IBOutlet UILabel *nameL;
@property (nonatomic,strong) DHModel *model;

@end

NS_ASSUME_NONNULL_END
