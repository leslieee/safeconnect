//
//  SLState.h
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SLState : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) BOOL isSaved;
@property (nonatomic, strong) NSString *stime;
@property (nonatomic, assign) double note;
@property (nonatomic, assign) BOOL hasLock;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
