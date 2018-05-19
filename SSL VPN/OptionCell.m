//
//  OptionCell.m
//  SSLVPN
//
//  Created by 陈强 on 16/12/1.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import "OptionCell.h"

@implementation OptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deletButton:(id)sender {
    
    if (self.deletConnect != nil) {
        
        
        self.deletConnect(self);
    }
}
- (IBAction)selectButton:(id)sender {
    
    if (self.selectConnect != nil) {
        self.selectConnect(self);
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
