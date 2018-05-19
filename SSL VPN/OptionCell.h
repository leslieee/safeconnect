//
//  OptionCell.h
//  SSLVPN
//
//  Created by 陈强 on 16/12/1.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OptionCell;
typedef void(^DELETE)(OptionCell*);
typedef void(^SELECT)(OptionCell*);
@interface OptionCell : UITableViewCell
@property(nonatomic,copy)DELETE deletConnect;
@property(nonatomic,copy)SELECT selectConnect;
@end
