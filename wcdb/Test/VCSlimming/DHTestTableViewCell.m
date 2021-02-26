//
//  DHTestTableViewCell.m
//  wcdb
//
//  Created by jabraknight on 2021/2/25.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "DHTestTableViewCell.h"

@implementation DHTestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(DHModel *)model{
    _model = model;
    self.nameL.text = model.nameStr;
    self.subName.text = model.nameSubStr;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
