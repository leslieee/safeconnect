//
//  HostToIP.m
//  SSL VPN
//
//  Created by shijia on 15/12/17.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "HostToIP.h"
#import <netdb.h>
#include <arpa/inet.h>

@implementation HostToIP

+(NSString*) getIP:(NSString*)strUrl
{
    NSLog(@"%@",strUrl);
    struct hostent *host_entry = gethostbyname([strUrl UTF8String]);
    if (host_entry==NULL)
    {   return strUrl;      }
    char* charIP = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    return [NSString stringWithCString:charIP encoding:NSUTF8StringEncoding];
}

@end
