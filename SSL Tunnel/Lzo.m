//
//  Lzo.m
//  SSL VPN
//
//  Created by shijia on 15/11/27.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "Lzo.h"
#import "Lzo/lzo1x.h"
#import "lzo/lzoutil.h"

@implementation Lzo

lzo_voidp wmem;

-(id)init
{
    if(self = [super init])
    {
        lzo_init();
        wmem=(lzo_voidp) lzo_malloc (LZO1X_1_15_MEM_COMPRESS);
    }
    return self;
}

-(NSData*) compressNSData:(NSData*) data
{
    unsigned long len = 0;
    unsigned char bufferWork[4096]= {};
    lzo1x_1_15_compress([data bytes], [data length], bufferWork, &len,wmem);
    return [[NSData alloc] initWithBytes:bufferWork length:len];
}

-(NSData*) decompressNSData:(NSData*) data
{
    unsigned long len = 0;
    unsigned char bufferWork[4096]= {};
    lzo1x_decompress([data bytes],[data length] ,bufferWork,&len,lzo1x_1_15_compress);
    return [[NSData alloc] initWithBytes:bufferWork length:len];
}

@end
