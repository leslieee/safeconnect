//
//  Crypto.m
//  SSL VPN
//
//  Created by shijia on 15/10/28.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "Crypto.h"
#import <openssl/hmac.h>
#import <openssl/evp.h>

@implementation Crypto

HMAC_CTX ctxEncryptHmac;
HMAC_CTX ctxDecryptHmac;
EVP_CIPHER_CTX ctxEncryptCipher;
EVP_CIPHER_CTX ctxDecryptCipher;

-(id)init
{
    if(self = [super init])
    {
        HMAC_CTX_init(&ctxEncryptHmac);
        HMAC_CTX_init(&ctxDecryptHmac);
        EVP_CIPHER_CTX_init(&ctxEncryptCipher);
        EVP_CIPHER_CTX_init(&ctxDecryptCipher);
    }
    return self;
}

-(BOOL) restart:(NSData*) dataMasterSecret
{
    int chunk=((int)[dataMasterSecret length])/4;
    HMAC_Init_ex (&ctxEncryptHmac, [dataMasterSecret bytes]+chunk,20, EVP_get_digestbyname("SHA1"), NULL);
    HMAC_Init_ex (&ctxDecryptHmac, [dataMasterSecret bytes]+chunk*3,20, EVP_get_digestbyname("SHA1"), NULL);
    EVP_CipherInit(&ctxEncryptCipher, EVP_get_cipherbyname ("BF-CBC"),[dataMasterSecret bytes], NULL,1);
    EVP_CipherInit(&ctxDecryptCipher, EVP_get_cipherbyname ("BF-CBC"),[dataMasterSecret bytes]+chunk*2, NULL,0);
    return true;
}

-(NSData*) creatDataIV
{
    NSMutableData* data=[[NSMutableData alloc] init];
    for (int i=0; i<4; i++)
    {
        int t=arc4random();
        [data appendBytes:&t length:4];
    }
    return  [data subdataWithRange:NSMakeRange(0, EVP_CIPHER_CTX_iv_length(&ctxEncryptCipher))];
}

-(NSData*) encryptData:(NSData*)data
{
    NSMutableData* dataCipher=[[NSMutableData alloc] init];
    unsigned char outbuf[4096]= {};
    int outlen=0;
    unsigned int hmaclen = 0;
    //iv
    NSData* dataIV=[self creatDataIV];
    [dataCipher appendData:dataIV];
    //加密
    EVP_CipherInit (&ctxEncryptCipher, NULL, NULL, [dataIV bytes], -1);
    EVP_CipherUpdate (&ctxEncryptCipher,outbuf, &outlen, [data bytes], (int)[data length]);
    [dataCipher appendBytes:outbuf length:outlen];
    EVP_CipherFinal (&ctxEncryptCipher, outbuf ,&outlen);
    [dataCipher appendBytes:outbuf length:outlen];//是否有一个字节的0
    //hmac
    HMAC_Init_ex(&ctxEncryptHmac, NULL, 0, NULL, NULL);
    HMAC_Update (&ctxEncryptHmac, [dataCipher bytes], (int)[dataCipher length]);
    HMAC_Final (&ctxEncryptHmac,outbuf,&hmaclen);
    //
    NSMutableData* dataEncrypt=[[NSMutableData alloc] init];
    [dataEncrypt appendBytes:outbuf length:hmaclen];
    [dataEncrypt appendData:dataCipher];
    return dataEncrypt;
}

-(NSData*) decryptData:(NSData*)data
{
    unsigned char outbuf[4096]= {};
    int outlen=0;
    //unsigned int hmaclen = 0;
    //hmac校验
    //HMAC_Init_ex(&ctxDecryptHmac, NULL, 0, NULL, NULL);
    //HMAC_Update (&ctxDecryptHmac,  [data bytes]+20, (int)[data length]-20);
    //HMAC_Final (&ctxDecryptHmac,outbuf,&hmaclen);
    //NSData* dataHmac=[[NSData alloc] initWithBytes:outbuf length:hmaclen];
    //if (dataHmac!=[data subdataWithRange:NSMakeRange(0, hmaclen)])
    //{   return [[NSData alloc] init];   }
    //解密
    NSMutableData* dataDecrypt=[[NSMutableData alloc] init];
    EVP_CipherInit (&ctxDecryptCipher ,NULL, NULL, [data bytes] +20, -1);
    EVP_CipherUpdate (&ctxDecryptCipher, outbuf, &outlen, [data bytes]+28, (int)[data length]-28);
    [dataDecrypt appendBytes:outbuf length:outlen];
    EVP_CipherFinal (&ctxDecryptCipher, outbuf ,&outlen);
    [dataDecrypt appendBytes:outbuf length:outlen];
    return dataDecrypt;
}

@end
