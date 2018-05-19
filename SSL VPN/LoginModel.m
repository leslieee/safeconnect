//
//  LoginModel.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "LoginModel.h"
#import "State.h"
#import "Data.h"


NSString *const kLoginModelCode = @"code";
NSString *const kLoginModelMessagePara = @"messagePara";
NSString *const kLoginModelState = @"state";
NSString *const kLoginModelData = @"data";
NSString *const kLoginModelMessage = @"message";


@interface LoginModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LoginModel

@synthesize code = _code;
@synthesize messagePara = _messagePara;
@synthesize state = _state;
@synthesize data = _data;
@synthesize message = _message;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.code = [[self objectOrNilForKey:kLoginModelCode fromDictionary:dict] doubleValue];
            self.messagePara = [self objectOrNilForKey:kLoginModelMessagePara fromDictionary:dict];
            self.state = [State modelObjectWithDictionary:[dict objectForKey:kLoginModelState]];
            self.data = [Data modelObjectWithDictionary:[dict objectForKey:kLoginModelData]];
            self.message = [self objectOrNilForKey:kLoginModelMessage fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.code] forKey:kLoginModelCode];
    NSMutableArray *tempArrayForMessagePara = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.messagePara) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForMessagePara addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForMessagePara addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForMessagePara] forKey:kLoginModelMessagePara];
    [mutableDict setValue:[self.state dictionaryRepresentation] forKey:kLoginModelState];
    [mutableDict setValue:[self.data dictionaryRepresentation] forKey:kLoginModelData];
    [mutableDict setValue:self.message forKey:kLoginModelMessage];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description  {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.code = [aDecoder decodeDoubleForKey:kLoginModelCode];
    self.messagePara = [aDecoder decodeObjectForKey:kLoginModelMessagePara];
    self.state = [aDecoder decodeObjectForKey:kLoginModelState];
    self.data = [aDecoder decodeObjectForKey:kLoginModelData];
    self.message = [aDecoder decodeObjectForKey:kLoginModelMessage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_code forKey:kLoginModelCode];
    [aCoder encodeObject:_messagePara forKey:kLoginModelMessagePara];
    [aCoder encodeObject:_state forKey:kLoginModelState];
    [aCoder encodeObject:_data forKey:kLoginModelData];
    [aCoder encodeObject:_message forKey:kLoginModelMessage];
}

- (id)copyWithZone:(NSZone *)zone {
    LoginModel *copy = [[LoginModel alloc] init];
    
    
    
    if (copy) {

        copy.code = self.code;
        copy.messagePara = [self.messagePara copyWithZone:zone];
        copy.state = [self.state copyWithZone:zone];
        copy.data = [self.data copyWithZone:zone];
        copy.message = [self.message copyWithZone:zone];
    }
    
    return copy;
}


@end
