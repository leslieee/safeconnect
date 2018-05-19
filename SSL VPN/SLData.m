//
//  SLData.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "SLData.h"


NSString *const kSLDataAddress = @"address";
NSString *const kSLDataPassword = @"password";
NSString *const kSLDataPort = @"port";
NSString *const kSLDataDisplayName = @"displayName";
NSString *const kSLDataPathname = @"pathname";
NSString *const kSLDataVsysId = @"vsysId";
NSString *const kSLDataUsername = @"username";
NSString *const kSLDataType = @"type";
NSString *const kSLDataComment = @"comment";
NSString *const kSLDataName = @"name";
NSString *const kSLDataFirstPath = @"firstPath";


@interface SLData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SLData

@synthesize address = _address;
@synthesize password = _password;
@synthesize port = _port;
@synthesize displayName = _displayName;
@synthesize pathname = _pathname;
@synthesize vsysId = _vsysId;
@synthesize username = _username;
@synthesize type = _type;
@synthesize comment = _comment;
@synthesize name = _name;
@synthesize firstPath = _firstPath;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.address = [self objectOrNilForKey:kSLDataAddress fromDictionary:dict];
            self.password = [self objectOrNilForKey:kSLDataPassword fromDictionary:dict];
            self.port = [[self objectOrNilForKey:kSLDataPort fromDictionary:dict] doubleValue];
            self.displayName = [self objectOrNilForKey:kSLDataDisplayName fromDictionary:dict];
            self.pathname = [self objectOrNilForKey:kSLDataPathname fromDictionary:dict];
            self.vsysId = [[self objectOrNilForKey:kSLDataVsysId fromDictionary:dict] doubleValue];
            self.username = [self objectOrNilForKey:kSLDataUsername fromDictionary:dict];
            self.type = [self objectOrNilForKey:kSLDataType fromDictionary:dict];
            self.comment = [self objectOrNilForKey:kSLDataComment fromDictionary:dict];
            self.name = [self objectOrNilForKey:kSLDataName fromDictionary:dict];
            self.firstPath = [self objectOrNilForKey:kSLDataFirstPath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForAddress = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.address) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAddress addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAddress addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAddress] forKey:kSLDataAddress];
    [mutableDict setValue:self.password forKey:kSLDataPassword];
    [mutableDict setValue:[NSNumber numberWithDouble:self.port] forKey:kSLDataPort];
    [mutableDict setValue:self.displayName forKey:kSLDataDisplayName];
    [mutableDict setValue:self.pathname forKey:kSLDataPathname];
    [mutableDict setValue:[NSNumber numberWithDouble:self.vsysId] forKey:kSLDataVsysId];
    [mutableDict setValue:self.username forKey:kSLDataUsername];
    [mutableDict setValue:self.type forKey:kSLDataType];
    [mutableDict setValue:self.comment forKey:kSLDataComment];
    [mutableDict setValue:self.name forKey:kSLDataName];
    [mutableDict setValue:self.firstPath forKey:kSLDataFirstPath];

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

    self.address = [aDecoder decodeObjectForKey:kSLDataAddress];
    self.password = [aDecoder decodeObjectForKey:kSLDataPassword];
    self.port = [aDecoder decodeDoubleForKey:kSLDataPort];
    self.displayName = [aDecoder decodeObjectForKey:kSLDataDisplayName];
    self.pathname = [aDecoder decodeObjectForKey:kSLDataPathname];
    self.vsysId = [aDecoder decodeDoubleForKey:kSLDataVsysId];
    self.username = [aDecoder decodeObjectForKey:kSLDataUsername];
    self.type = [aDecoder decodeObjectForKey:kSLDataType];
    self.comment = [aDecoder decodeObjectForKey:kSLDataComment];
    self.name = [aDecoder decodeObjectForKey:kSLDataName];
    self.firstPath = [aDecoder decodeObjectForKey:kSLDataFirstPath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_address forKey:kSLDataAddress];
    [aCoder encodeObject:_password forKey:kSLDataPassword];
    [aCoder encodeDouble:_port forKey:kSLDataPort];
    [aCoder encodeObject:_displayName forKey:kSLDataDisplayName];
    [aCoder encodeObject:_pathname forKey:kSLDataPathname];
    [aCoder encodeDouble:_vsysId forKey:kSLDataVsysId];
    [aCoder encodeObject:_username forKey:kSLDataUsername];
    [aCoder encodeObject:_type forKey:kSLDataType];
    [aCoder encodeObject:_comment forKey:kSLDataComment];
    [aCoder encodeObject:_name forKey:kSLDataName];
    [aCoder encodeObject:_firstPath forKey:kSLDataFirstPath];
}

- (id)copyWithZone:(NSZone *)zone {
    SLData *copy = [[SLData alloc] init];
    
    
    
    if (copy) {

        copy.address = [self.address copyWithZone:zone];
        copy.password = [self.password copyWithZone:zone];
        copy.port = self.port;
        copy.displayName = [self.displayName copyWithZone:zone];
        copy.pathname = [self.pathname copyWithZone:zone];
        copy.vsysId = self.vsysId;
        copy.username = [self.username copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.comment = [self.comment copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.firstPath = [self.firstPath copyWithZone:zone];
    }
    
    return copy;
}


@end
