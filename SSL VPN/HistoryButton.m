//
//  HistoryButton.m
//  SSLVPN
//
//  Created by 陈强 on 16/12/7.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import "HistoryButton.h"

@implementation HistoryButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)buttonDidclick:(id)sender {
    
    if (   self.clickBlock != nil) {
          self.clickBlock();
    }
 
    
}

@end
