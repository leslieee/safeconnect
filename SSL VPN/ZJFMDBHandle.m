//
//  ZJFMDBHandle.m
//  MVVMReactiveCocoa
//
//  Created by 余京谷 on 16/11/10.
//  Copyright © 2016年 KanJian. All rights reserved.
//

#define string(str1,str2) [NSString stringWithFormat:@"%@%@",str1,str2]

// LOG PRINT
// The general purpose logger. This ignores logging levels.
#ifdef ITTDEBUG
#define ITTDPRINT(xx, ...)      NSLog(@"< %s:(%d) > : " xx , __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define ITTDPRINT(xx, ...)      ((void)0)
#endif

#import "ZJFMDBHandle.h"
#import <FMDB/FMDatabase.h>
#import <objc/runtime.h>

@interface ZJFMDBHandle()
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ZJFMDBHandle

+ (instancetype)manager {

    
    static ZJFMDBHandle *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (BOOL)creatPersonTable:(NSObject *)model {
    
    BOOL isOpen = [self.db open];
    BOOL isCreat;
    if (isOpen) {
       
        NSString *className = NSStringFromClass([model class]);
        
        NSString *modelName = [self getAllProperties:model];
        
        NSString *tableName = [NSString stringWithFormat:@"CREATE TABLE '%@'('%@' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,%@)",className,@"id",modelName];
        
        isCreat = [self.db executeUpdate:tableName];
        
        [_db close];
        
        ITTDPRINT(@"%@",isCreat ? @"creatPersonTable YES":@"creatPersonTable NO");
    } else {
        ITTDPRINT(@"NO Open sqlite");
    }
    return isCreat;
}


// 根据detectingdate删除某个咨询对话 add by bob
-(void)deleteModel:(NSString*)connectName {
    
    [self.db open];
    
    NSLog(@"%d", [self.db executeUpdate:@"DELETE FROM ZJModel WHERE connectName = ?",connectName]);
   
}

- (void)insertPersonTable:(NSObject *)model {
    
     [self.db open];
    
    NSArray *strings = [self getAllPropertiesInsert:model];
    NSString *className = NSStringFromClass([model class]);
    
    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ",className]];
    if (!res) {
        [_db close];
        
        [self creatPersonTable:model];
        [self.db open];
    }
  
   BOOL isInsert = [_db executeUpdate:
                    [NSString stringWithFormat:@"INSERT INTO %@(%@)VALUES(%@)",className,
                        strings.firstObject,
                        strings.lastObject]
                 withArgumentsInArray:strings[1]];

    NSLog(@"%@",isInsert ? @"插入成功":@"插入失败");
    
//  限制最多存储32个信息
    [self.db executeUpdate:@"DELETE FROM ZJModel WHERE (select count(Id) from ZJModel)> 32 and Id in (select Id from ZJModel order by Id ASC limit 1)"];
    
    
     [_db close];
}

- (NSMutableArray *)selectAllPersonFromPersonTable:(Class)model {
    
    [self.db open];

    NSString *className = NSStringFromClass([model class]);

    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ",className]];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    while ([res next]) {
        [array addObject:[res resultDictionary]];
    }
    [_db close];
    return array;
}

- (NSString *)dbpath{
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Table.sqlite",app_Version]];
    
    return filePath;
}

- (NSArray *)getAllPropertiesInsert:(id)obj {
    
    u_int count;
    NSMutableString *keys = [NSMutableString new];
    NSMutableArray *values = [NSMutableArray new];
    NSMutableString *class = [NSMutableString new];
    objc_property_t *properties  =class_copyPropertyList([obj class], &count);
    for (int i = 0; i<count; i++) {
        
        const char* propertyName =property_getName(properties[i]);
        
        id value = [obj valueForKey:[NSString stringWithUTF8String: propertyName]];
        
        [keys appendFormat:@"%@,",[NSString stringWithUTF8String: propertyName]];
        [class appendFormat:@"?,"];
        
        if ([value isKindOfClass:[NSString class]]) {
            [values addObject:value];
        }else if ([value isKindOfClass:[NSData class]]) {
            [values addObject:value];
        } else {
            int index = [value integerValue];
            [values addObject:@(index)];
        }
    }
    free(properties);
    return @[[keys substringToIndex:keys.length - 1],
             values,
             [class substringToIndex:class.length - 1]];
}

- (NSString *)getAllProperties:(id)obj {
    
    u_int count;
    NSMutableString *string = [NSMutableString new];
    
    objc_property_t *properties  =class_copyPropertyList([obj class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        
        const char* propertyName =property_getName(properties[i]);

        NSString *key = [NSString stringWithUTF8String: propertyName];
        
        if ([key isEqualToString:@"ID"]) {
            continue;
        }
        
        NSString *valueKey;
        id value = [obj valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            valueKey = @"VARCHAR(255)";//@"text";
        }else if ([value isKindOfClass:[NSData class]]) {
            valueKey = @"blob";
        } else {
            valueKey = @"integer";
        }
        
        [string appendFormat:@"'%@' %@,",[NSString stringWithUTF8String: propertyName],valueKey];
        
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return [string substringToIndex:string.length - 1];
}

- (FMDatabase *)db {

    if (!_db) {
        _db = [FMDatabase databaseWithPath:[self dbpath]];
    }
    return _db;
}

@end
