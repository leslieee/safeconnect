//
//  HistoryButton.h
//  SSLVPN
//
//  Created by 陈强 on 16/12/7.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ButtonDidClickBlock)(void);
@interface HistoryButton : UIView
@property (nonatomic, copy)ButtonDidClickBlock clickBlock;



@end
