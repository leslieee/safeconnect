//
//  MasterSecret.m
//  SSL VPN
//
//  Created by shijia on 15/11/9.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "MasterSecret.h"
#import <openssl/evp.h>
#import <openssl/hmac.h>
#import <openssl/md5.h>

@implementation MasterSecret

unsigned char bytesLabel1[]= {0x4f,0x70,0x65,0x6e,0x56,0x50,0x4e,0x20,0x6d,0x61,0x73,0x74,0x65,0x72,0x20,0x73,0x65,0x63,0x72,0x65,0x74};//"OpenVPN master secret"
unsigned char bytesLabel2[]= {0x4f,0x70,0x65,0x6e,0x56,0x50,0x4e,0x20,0x6b,0x65,0x79,0x20,0x65,0x78,0x70,0x61,0x6e,0x73,0x69,0x6f,0x6e};//"OpenVPN key expansion"

+(NSData*) creatMasterSecret:(NSData*)dataOptionClient OptionServer:(NSData*)dataOptionServer sessionClient:(NSData*)sessionCilent sessionServer:(NSData*)sessionServer
{
    NSData* dataPreMaster=[dataOptionClient subdataWithRange:NSMakeRange(5, 48)];
    NSData* dataLabel1=[[NSData alloc] initWithBytes: bytesLabel1 length:sizeof(bytesLabel1)] ;
    NSData* dataLabel2=[[NSData alloc] initWithBytes: bytesLabel2 length:sizeof(bytesLabel2)] ;
    NSData *dataRandomClient1=[dataOptionClient subdataWithRange:NSMakeRange(53, 32)];
    NSData *dataRandomClient2=[dataOptionClient subdataWithRange:NSMakeRange(85, 32)];
    NSData *dataRandomServer1=[dataOptionServer subdataWithRange:NSMakeRange(5, 32)];
    NSData *dataRandomServer2=[dataOptionServer subdataWithRange:NSMakeRange(37, 32)];
    //
    NSData *dataMaster=[self openvpnPRF:dataPreMaster label:dataLabel1 seedClient:dataRandomClient1 seedServer:dataRandomServer1 sessionCilent:[[NSData alloc] init] sessionServer:[[NSData alloc] init] len:48];
    return [self openvpnPRF:dataMaster label:dataLabel2 seedClient:dataRandomClient2 seedServer:dataRandomServer2 sessionCilent:sessionCilent sessionServer:sessionServer len:256];
}

+(NSData*) tls1PRF:(NSData*) dataSec label:(NSData*) dataLabel length:(int)len
{
    NSData* dataS1=[dataSec subdataWithRange:NSMakeRange(0, dataSec.length/2)];
    NSData* dataS2=[dataSec subdataWithRange:NSMakeRange(dataSec.length/2, dataSec.length/2)];
    NSData* dataOut1= [self tls1Phash:"MD5"  sec:dataS1 seed:dataLabel length:len];
    NSData* dataOut2= [self tls1Phash:"SHA1" sec:dataS2 seed:dataLabel length:len];
    unsigned char* s1=(unsigned char*)[dataOut1 bytes];
    unsigned char* s2=(unsigned char*)[dataOut2 bytes];
    for (int i=0; i<len; i++)
    {   s1[i] ^= s2[i] ;   }
    return dataOut1;
}

+(NSData*) tls1Phash:(const char*) nameEVP sec:(NSData*) dataSec seed:(NSData*) dataSeed length:(int)len
{
    const EVP_MD *md = EVP_get_digestbyname(nameEVP);
    int chunk = EVP_MD_size(md);
    uint8_t A1[64]={0};
    unsigned int temp = 0;
    HMAC_CTX ctx;
    HMAC_CTX ctx_tmp;
    HMAC_CTX_init(&ctx);
    HMAC_CTX_init(&ctx_tmp);
    HMAC_Init_ex (&ctx, [dataSec bytes], (int)[dataSec length], md, NULL);
    HMAC_Init_ex (&ctx_tmp, [dataSec bytes], (int)[dataSec length], md, NULL);
    HMAC_Update (&ctx, [dataSeed bytes], [dataSeed length]);
    HMAC_Final (&ctx,A1,&temp);
    unsigned char out[64]={0};
    NSMutableData *data=[[NSMutableData alloc] init];
    while (true)
    {
        HMAC_Init_ex (&ctx, NULL, 0, NULL, NULL);
        HMAC_Init_ex (&ctx_tmp, NULL, 0, NULL, NULL);
        HMAC_Update  (&ctx, A1,chunk);
        HMAC_Update  (&ctx_tmp, A1,chunk);
        HMAC_Update  (&ctx, [dataSeed bytes],[dataSeed length]);
        if (len > chunk)
        {
            HMAC_Final(&ctx,out,&temp);
            [data appendBytes:out length:chunk ];
            len-=chunk;
            HMAC_Final(&ctx_tmp, A1,&temp);
        }
        else
        {
            HMAC_Final(&ctx, out,&temp);
            [data appendBytes:out length:len ];
            return data;
        }
    }
}

+(NSData*) openvpnPRF:(NSData*)dataSecret label:(NSData*) dataLabel seedClient:(NSData*)dataSeedClient seedServer:(NSData*)dataSeedServer sessionCilent:(NSData*)dataIdClient sessionServer:(NSData*)dataIdServer len:(int)len
{
    NSMutableData *data=[[NSMutableData alloc] init];
    [data appendData:dataLabel];
    [data appendData:dataSeedClient];
    [data appendData:dataSeedServer];
    [data appendData:dataIdClient];
    [data appendData:dataIdServer];
    return  [self tls1PRF:dataSecret label:data length:len];
}
@end
