//
//  YUTestViewController.h
//  YUFoldingTableViewDemo
//
//  Created by administrator on 16/8/25.
//  Copyright © 2016年 xuanYuLin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUFoldingTableView.h"
typedef void(^SendBlock)(NSDictionary*model);
@interface YUTestViewController : UIViewController

@property (nonatomic, assign) YUFoldingSectionHeaderArrowPosition arrowPosition;
@property (nonatomic, copy)SendBlock selectConnectBlock;


@end
