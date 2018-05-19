//
//  SLState.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "SLState.h"


NSString *const kSLStateIsSaved = @"isSaved";
NSString *const kSLStateStime = @"stime";
NSString *const kSLStateNote = @"note";
NSString *const kSLStateHasLock = @"hasLock";


@interface SLState ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SLState

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
            self.isSaved = [[self objectOrNilForKey:kSLStateIsSaved fromDictionary:dict] boolValue];
            self.stime = [self objectOrNilForKey:kSLStateStime fromDictionary:dict];
            self.note = [[self objectOrNilForKey:kSLStateNote fromDictionary:dict] doubleValue];
            self.hasLock = [[self objectOrNilForKey:kSLStateHasLock fromDictionary:dict] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.isSaved] forKey:kSLStateIsSaved];
    [mutableDict setValue:self.stime forKey:kSLStateStime];
    [mutableDict setValue:[NSNumber numberWithDouble:self.note] forKey:kSLStateNote];
    [mutableDict setValue:[NSNumber numberWithBool:self.hasLock] forKey:kSLStateHasLock];

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

    self.isSaved = [aDecoder decodeBoolForKey:kSLStateIsSaved];
    self.stime = [aDecoder decodeObjectForKey:kSLStateStime];
    self.note = [aDecoder decodeDoubleForKey:kSLStateNote];
    self.hasLock = [aDecoder decodeBoolForKey:kSLStateHasLock];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_isSaved forKey:kSLStateIsSaved];
    [aCoder encodeObject:_stime forKey:kSLStateStime];
    [aCoder encodeDouble:_note forKey:kSLStateNote];
    [aCoder encodeBool:_hasLock forKey:kSLStateHasLock];
}

- (id)copyWithZone:(NSZone *)zone {
    SLState *copy = [[SLState alloc] init];
    
    
    
    if (copy) {

        copy.isSaved = self.isSaved;
        copy.stime = [self.stime copyWithZone:zone];
        copy.note = self.note;
        copy.hasLock = self.hasLock;
    }
    
    return copy;
}


@end
