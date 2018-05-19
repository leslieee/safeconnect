//
//  Crypto.h
//  SSL VPN
//
//  Created by shijia on 15/10/28.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crypto : NSObject
-(BOOL) restart:(NSData*) dataMasterSecret;
-(NSData*) encryptData:(NSData*)data;
-(NSData*) decryptData:(NSData*)data;
@end
