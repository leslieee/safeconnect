//
//  SLData.h
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SLData : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *address;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) double port;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *pathname;
@property (nonatomic, assign) double vsysId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstPath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
