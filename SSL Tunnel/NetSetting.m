//
//  NetSetting.m
//  SSL VPN
//
//  Created by 师佳 on 15/12/27.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "NetSetting.h"

//由于资源释放问题，每次解析都是步解析
//Optional("PUSH_REPLY,dhcp-option DNS 202.107.117.11,route 5.5.0.1,topology net30,ping 5,ping-restart 120,route 192.168.6.41 255.255.255.255,route 192.168.6.42 255.255.255.255,route 192.168.7.29 255.255.255.255,route 192.168.7.32 255.255.255.255,route 192.168.6.23 255.255.255.255,route 192.168.6.23 255.255.255.255,route 192.168.6.28 255.255.255.255,route 192.168.6.24 255.255.255.255,route 192.168.6.47 255.255.255.255,route 192.168.6.47 255.255.255.255,route 192.168.6.81 255.255.255.255,route 192.168.6.122 255.255.255.255,route 192.168.6.32 255.255.255.255,route 192.168.6.20 255.255.255.255,route 192.168.6.99 255.255.255.255,route 192.168.2.21 255.255.255.255,route 192.168.7.26 255.255.255.255,route 192.168.1.21 255.255.255.255,route 218.25.39.39 255.255.255.255,route 192.168.6.48 255.255.255.255,route 192.168.2.141 255.255.255.255,route 192.168.2.141 255.255.255.255,route 218.25.39.39 255.255.255.255,route 192.168.21.51 255.255.255.255,push-continuation 2\0PUSH_REPLY,route 192.168.21.37 255.255.255.255,route 202.107.117.11 255.255.255.255,ifconfig 5.5.0.6 5.5.0.5,push-continuation 1\0")

@implementation NetSetting

NSMutableData *dataNetSetting;

-(id)init
{
    if(self = [super init])
    {
        _ping=5;
        _pingRestart=120;
        dataNetSetting=[[NSMutableData alloc] init];
    }
    return self;
}

-(BOOL) add:(NSData*) data
{
    NSString* str=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    
    if([str containsString:@"RECONNECTING"]){
        
    
         self.reConnecting = @"RECONNECTING";
        
      
        
    };
    
    if([str hasPrefix:@"PUSH_REPLY"])
    {   [dataNetSetting appendData:data];   }
    else
    {   return false;   }
    //
    if ([dataNetSetting length]<=0)
    {   return false;   }
    //
    
    
  
    NSString* strNet=[[NSString alloc] initWithBytes:[dataNetSetting bytes] length:[dataNetSetting length] encoding:NSASCIIStringEncoding];
    if([strNet containsString:@"RECONNECTING"]){
        
        
        self.reConnecting = @"RECONNECTING";
        
    };
    
    if ([strNet rangeOfString:@"push-continuation"].location==NSNotFound)
    {
        [self parseIfconfig:dataNetSetting];
        [self parseDNS:dataNetSetting];
        [self parseRoute:dataNetSetting];
        [self parsePing:dataNetSetting];
        [self parsePingRestart:dataNetSetting];
        return true;
    }
    else
    {
        if ([strNet rangeOfString:@"push-continuation 2"].location!=NSNotFound && [strNet rangeOfString:@"push-continuation 1"].location!=NSNotFound)
        {
            [self parseIfconfig:dataNetSetting];
            [self parseDNS:dataNetSetting];
            [self parseRoute:dataNetSetting];
            [self parsePing:dataNetSetting];
            [self parsePingRestart:dataNetSetting];
            return true;
        }
        else
        {   return false;   }
    }
    
}

-(NSData*) getData;
{   return dataNetSetting;  }

//解析,由于资源释放导致该部分有问题
-(BOOL) parse:(NSString*)strNetSetting
{
    NSArray* strList=[strNetSetting componentsSeparatedByString:@","];
    NSMutableArray *dns=[[NSMutableArray alloc] init];
    NSMutableArray *routeIp=[[NSMutableArray alloc] init];
    NSMutableArray *routeMasks=[[NSMutableArray alloc] init];
    NSMutableArray *adressIp=[[NSMutableArray alloc] init];
    NSMutableArray *adressMasks=[[NSMutableArray alloc] init];
    for (NSString *str in strList)
    {
        if ([str hasPrefix:@"dhcp-option DNS"])
        {   [dns addObject:[str substringFromIndex:[@"dhcp-option DNS " length]]];   }
        else if([str hasPrefix:@"ifconfig"])
        {
            NSArray* list=[str componentsSeparatedByString:@" "];
            if ([list count]>=1)
            {
                [adressIp addObject:[list objectAtIndex:1]];
                [adressMasks addObject:@"255.255.255.255"];
            }
        }
        else if([str hasPrefix:@"route"])
        {
            NSArray* list=[str componentsSeparatedByString:@" "];
            if ([list count]==3)
            {
                [routeIp addObject:[list objectAtIndex:1]];
                [routeMasks addObject:[list objectAtIndex:2]];
            }
            else if ([list count]==2)
            {
                [routeIp addObject:[list objectAtIndex:1]];
                [routeMasks addObject:@"255.255.255.255"];
            }
        }
    }
    self.dnsList=dns;
    self.adressIpList=adressIp;
    self.adressMasksList=adressMasks;
    self.routeIpList=routeIp;
    self.routeMasksList=routeMasks;
    return  true;
}

//解析路由表
-(void) parseRoute:(NSData* )data
{
    NSMutableArray *routeIp=[[NSMutableArray alloc] init];
    NSMutableArray *routeMasks=[[NSMutableArray alloc] init];
    for (NSString *str in [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","])
    {
        if([str hasPrefix:@"route"])
        {
            NSArray* list=[str componentsSeparatedByString:@" "];
            
            if ([list count]==3)
            {
                [routeIp addObject:[list objectAtIndex:1]];
                [routeMasks addObject:[list objectAtIndex:2]];
            }
            else if ([list count]==2)
            {
                [routeIp addObject:[list objectAtIndex:1]];
                [routeMasks addObject:@"255.255.255.255"];
            }
        }
    }
    self.routeIpList=routeIp;
    self.routeMasksList=routeMasks;
}

//解析DNS
-(void) parseDNS:(NSData* )data
{
    NSMutableArray *dns=[[NSMutableArray alloc] init];
    for (NSString *str in [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","])
    {
        if ([str hasPrefix:@"dhcp-option DNS"])
        {   [dns addObject:[str substringFromIndex:[@"dhcp-option DNS " length]]];   }
    }
    self.dnsList=dns;
}

//解析IP
-(void) parseIfconfig:(NSData* )data
{
    NSMutableArray *adressIp=[[NSMutableArray alloc] init];
    NSMutableArray *adressMasks=[[NSMutableArray alloc] init];
    for (NSString *str in [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","])
    {
        if([str hasPrefix:@"ifconfig"])
        {
            NSArray* list=[str componentsSeparatedByString:@" "];
            if ([list count]>=1)
            {
                [adressIp addObject:[list objectAtIndex:1]];
                [adressMasks addObject:@"255.255.255.255"];
            }
            break;
        }
    }
    self.adressIpList=adressIp;
    self.adressMasksList=adressMasks;
}

//解析ping
-(void) parsePing:(NSData* )data;
{
    for (NSString *str in [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","])
    {
        if([str hasPrefix:@"ping"])
        {
            self.ping = [[str substringFromIndex:[@"ping " length]] intValue];
            break;
        }
    }
}

//解析pingreStart
-(void) parsePingRestart:(NSData* )data
{
    for (NSString *str in [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","])
    {
        if([str hasPrefix:@"ping-restart"])
        {
            self.pingRestart = [[str substringFromIndex:[@"ping-restart " length]] intValue];

            break;
        }
    }
}

@end
