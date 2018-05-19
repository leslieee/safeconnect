//
//  Data.m
//
//  Created by 强 陈 on 2017/8/8
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "Data.h"


NSString *const kDataCertificate = @"certificate";
NSString *const kDataOtpAuth = @"otp_auth";
NSString *const kDataVerifyClient = @"verify_client";


@interface Data ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Data

@synthesize certificate = _certificate;
@synthesize otpAuth = _otpAuth;
@synthesize verifyClient = _verifyClient;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.certificate = [self objectOrNilForKey:kDataCertificate fromDictionary:dict];
            self.otpAuth = [self objectOrNilForKey:kDataOtpAuth fromDictionary:dict];
            self.verifyClient = [self objectOrNilForKey:kDataVerifyClient fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.certificate forKey:kDataCertificate];
    [mutableDict setValue:self.otpAuth forKey:kDataOtpAuth];
    [mutableDict setValue:self.verifyClient forKey:kDataVerifyClient];

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

    self.certificate = [aDecoder decodeObjectForKey:kDataCertificate];
    self.otpAuth = [aDecoder decodeObjectForKey:kDataOtpAuth];
    self.verifyClient = [aDecoder decodeObjectForKey:kDataVerifyClient];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_certificate forKey:kDataCertificate];
    [aCoder encodeObject:_otpAuth forKey:kDataOtpAuth];
    [aCoder encodeObject:_verifyClient forKey:kDataVerifyClient];
}

- (id)copyWithZone:(NSZone *)zone {
    Data *copy = [[Data alloc] init];
    
    
    
    if (copy) {

        copy.certificate = [self.certificate copyWithZone:zone];
        copy.otpAuth = [self.otpAuth copyWithZone:zone];
        copy.verifyClient = [self.verifyClient copyWithZone:zone];
    }
    
    return copy;
}


@end
