//
//  SLSourceListModel.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "SLSourceListModel.h"
#import "SLState.h"
#import "SLData.h"


NSString *const kSLSourceListModelCode = @"code";
NSString *const kSLSourceListModelMessagePara = @"messagePara";
NSString *const kSLSourceListModelState = @"state";
NSString *const kSLSourceListModelData = @"data";
NSString *const kSLSourceListModelMessage = @"message";


@interface SLSourceListModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SLSourceListModel

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
            self.code = [[self objectOrNilForKey:kSLSourceListModelCode fromDictionary:dict] doubleValue];
            self.messagePara = [self objectOrNilForKey:kSLSourceListModelMessagePara fromDictionary:dict];
            self.state = [SLState modelObjectWithDictionary:[dict objectForKey:kSLSourceListModelState]];
    NSObject *receivedSLData = [dict objectForKey:kSLSourceListModelData];
    NSMutableArray *parsedSLData = [NSMutableArray array];
    
    if ([receivedSLData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedSLData) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedSLData addObject:[SLData modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedSLData isKindOfClass:[NSDictionary class]]) {
       [parsedSLData addObject:[SLData modelObjectWithDictionary:(NSDictionary *)receivedSLData]];
    }

    self.data = [NSArray arrayWithArray:parsedSLData];
            self.message = [self objectOrNilForKey:kSLSourceListModelMessage fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.code] forKey:kSLSourceListModelCode];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForMessagePara] forKey:kSLSourceListModelMessagePara];
    [mutableDict setValue:[self.state dictionaryRepresentation] forKey:kSLSourceListModelState];
    NSMutableArray *tempArrayForData = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.data) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForData addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForData addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForData] forKey:kSLSourceListModelData];
    [mutableDict setValue:self.message forKey:kSLSourceListModelMessage];

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

    self.code = [aDecoder decodeDoubleForKey:kSLSourceListModelCode];
    self.messagePara = [aDecoder decodeObjectForKey:kSLSourceListModelMessagePara];
    self.state = [aDecoder decodeObjectForKey:kSLSourceListModelState];
    self.data = [aDecoder decodeObjectForKey:kSLSourceListModelData];
    self.message = [aDecoder decodeObjectForKey:kSLSourceListModelMessage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_code forKey:kSLSourceListModelCode];
    [aCoder encodeObject:_messagePara forKey:kSLSourceListModelMessagePara];
    [aCoder encodeObject:_state forKey:kSLSourceListModelState];
    [aCoder encodeObject:_data forKey:kSLSourceListModelData];
    [aCoder encodeObject:_message forKey:kSLSourceListModelMessage];
}

- (id)copyWithZone:(NSZone *)zone {
    SLSourceListModel *copy = [[SLSourceListModel alloc] init];
    
    
    
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
