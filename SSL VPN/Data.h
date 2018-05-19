//
//  Data.h
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Data : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *certificate;
@property (nonatomic, strong) NSString *otpAuth;
@property (nonatomic, strong) NSString *verifyClient;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
