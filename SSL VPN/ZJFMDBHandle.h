//
//  ZJFMDBHandle.h
//  MVVMReactiveCocoa
//
//  Created by 余京谷 on 16/11/10.
//  Copyright © 2016年 KanJian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJFMDBHandle : NSObject

+ (instancetype)manager;

- (BOOL)creatPersonTable:(NSObject *)model;
-(void)deleteModel:(NSString*)connectName;
/**
 *  function 添加数据
 *
 *  param 所添加的数据model
 */
- (void)insertPersonTable:(NSObject *)model;

/**
 *  function 获取某个表的数据
 *
 *  param 类名
 */
- (NSMutableArray *)selectAllPersonFromPersonTable:(Class)model;

@end
