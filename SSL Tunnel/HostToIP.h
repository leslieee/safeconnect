//
//  HostToIP.h
//  SSL VPN
//
//  Created by shijia on 15/12/17.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HostToIP : NSObject
+(NSString*) getIP:(NSString*)strUrl;
@end
