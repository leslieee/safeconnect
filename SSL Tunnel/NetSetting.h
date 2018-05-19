//
//  NetSetting.h
//  SSL VPN
//
//  Created by 师佳 on 15/12/27.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetSetting : NSObject
@property NSArray *dnsList,*adressIpList,*adressMasksList,*routeIpList,*routeMasksList;
@property int ping,pingRestart;
@property NSString *reConnecting;


-(id) init;
-(BOOL)add:(NSData*) data;
-(NSData*) getData;

@end
