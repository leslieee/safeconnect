//
//  State.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "State.h"


NSString *const kStateIsSaved = @"isSaved";
NSString *const kStateStime = @"stime";
NSString *const kStateNote = @"note";
NSString *const kStateHasLock = @"hasLock";


@interface State ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation State

@synthesize isSaved = _isSaved;
@synthesize stime = _stime;
@synthesize note = _note;
@synthesize hasLock = _hasLock;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.isSaved = [[self objectOrNilForKey:kStateIsSaved fromDictionary:dict] boolValue];
            self.stime = [self objectOrNilForKey:kStateStime fromDictionary:dict];
            self.note = [[self objectOrNilForKey:kStateNote fromDictionary:dict] doubleValue];
            self.hasLock = [self objectOrNilForKey:kStateHasLock fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.isSaved] forKey:kStateIsSaved];
    [mutableDict setValue:self.stime forKey:kStateStime];
    [mutableDict setValue:[NSNumber numberWithDouble:self.note] forKey:kStateNote];
    [mutableDict setValue:self.hasLock forKey:kStateHasLock];

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

    self.isSaved = [aDecoder decodeBoolForKey:kStateIsSaved];
    self.stime = [aDecoder decodeObjectForKey:kStateStime];
    self.note = [aDecoder decodeDoubleForKey:kStateNote];
    self.hasLock = [aDecoder decodeObjectForKey:kStateHasLock];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_isSaved forKey:kStateIsSaved];
    [aCoder encodeObject:_stime forKey:kStateStime];
    [aCoder encodeDouble:_note forKey:kStateNote];
    [aCoder encodeObject:_hasLock forKey:kStateHasLock];
}

- (id)copyWithZone:(NSZone *)zone {
    State *copy = [[State alloc] init];
    
    
    
    if (copy) {

        copy.isSaved = self.isSaved;
        copy.stime = [self.stime copyWithZone:zone];
        copy.note = self.note;
        copy.hasLock = [self.hasLock copyWithZone:zone];
    }
    
    return copy;
}


@end
