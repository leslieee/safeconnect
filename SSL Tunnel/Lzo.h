//
//  Lzo.h
//  SSL VPN
//
//  Created by shijia on 15/11/27.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lzo : NSObject
-(id) init;
-(NSData*) compressNSData:(NSData*) data;
-(NSData*) decompressNSData:(NSData*) data;
@end
