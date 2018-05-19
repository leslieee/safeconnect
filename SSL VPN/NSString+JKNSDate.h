//
//  NSString+NSString_JKNSDate.h
//  
//
//  Created by Jacky on 15-4-28.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (NSString_JKNSDate)
- (NSString *)dateStringFromFormat:(NSString *)format toFormat:(NSString *)targetFormat;
- (NSDate *)dateFromStringWithFormat:(NSString *)format;
- (NSDate *)rssDateValue;
- (NSDate *)atomDateValue;
- (NSDate *)xmlrpcDateValue;
- (BOOL)isIPAddress;
@end
