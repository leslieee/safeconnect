//
//  MasterSecret.h
//  SSL VPN
//
//  Created by shijia on 15/11/9.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MasterSecret : NSObject
+(NSData*) creatMasterSecret:(NSData*)dataOptionClient OptionServer:(NSData*)dataOptionServer sessionClient:(NSData*)sessionCilent sessionServer:(NSData*)sessionServer;
@end
