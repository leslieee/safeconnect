//
//  CaAnalysisTool.m
//  Safe Connect
//
//  Created by 陈强 on 17/2/24.
//  Copyright © 2017年 shijia. All rights reserved.
//

#import "CaAnalysisTool.h"
#import <openssl/ssl.h>
#import <openssl/x509.h>

#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#include <openssl/err.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/pkcs12.h>
#include <openssl/bio.h>
//#include <openssl/err.h>
#include <openssl/pem.h>
#define CHK_NULL(x) if ((x)==NULL) exit (-1)
#define CHK_ERR(err,s) if ((err)==-1) { perror(s); exit(-2); }
#define CHK_SSL(err) if ((err)==-1) { ERR_print_errors_fp(stderr); exit(-3); }

@implementation CaAnalysisTool
    static CaAnalysisTool* _instance = nil;
+(instancetype) shareCaAnalysisToolInstance
    {
        static dispatch_once_t onceToken ;
        dispatch_once(&onceToken, ^{
            _instance = [[super allocWithZone:NULL] init] ;
        }) ;
        return _instance ;
    }
    
+(id) allocWithZone:(struct _NSZone *)zone
    {
        return [CaAnalysisTool shareCaAnalysisToolInstance] ;
    }
    
-(id) copyWithZone:(struct _NSZone *)zone
    {
        return [CaAnalysisTool shareCaAnalysisToolInstance] ;
    }
    
    -(void)PXFCaAnalysisWithPath:(NSString *)caPath{
    
     PKCS12 *p12 = NULL;
     X509 *usrCert = NULL;
     EVP_PKEY *pkey = NULL;
     STACK_OF(X509) *ca = NULL;
     BIO *bio;
     char pass[128]="1";
     
     //int i;
     char *p;
     char buf[1024];
     
     SSLeay_add_all_algorithms();
     ERR_load_crypto_strings();
     NSString*  path = caPath;
     const char * a =[path UTF8String];
     
     bio = BIO_new_file(a, "rb");
     p12 = d2i_PKCS12_bio(bio, NULL); //得到p12结构
     BIO_free_all(bio);
     PKCS12_parse(p12, pass, &pkey, &usrCert, &ca); //得到x509结构
     PKCS12_free(p12);
     
     
     
     if (pkey)
     {
         fprintf(stdout, "***Private Key***/n");
         PEM_write_PrivateKey(stdout, pkey, NULL, NULL, 0, NULL, NULL);
         unsigned char *buf, *pp;
         int len = i2d_PrivateKey(pkey, NULL);
         buf = OPENSSL_malloc(len);
         pp = buf;
         i2d_PrivateKey(pkey, &pp);
         
         NSData* pkeyData = [NSData dataWithBytes:(const void *)buf length:len];
         //        NSString *content =[ NSString stringWithCString:[pkeyData bytes] encoding:NSUTF8StringEncoding];
         //   NSString *myString = [[NSString alloc] initWithData:pkeyData encoding:NSUTF8StringEncoding];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ; //得到documents的路径，为当前应用程序独享
         
         NSString *documentD = [paths objectAtIndex:0];
         
         
         NSString *pkeyFile = [documentD stringByAppendingPathComponent:@"key.pem"]; //得到documents目录下dujw.plist配置文件的路径
         
         
         
         [pkeyData writeToFile:pkeyFile atomically:YES];
     
         
         
     }
     
     
     if (usrCert)
     {
         
         //        [self  writeConfigFile:usrCert];
         fprintf(stdout, "***User Certificate***/n");
         PEM_write_X509_AUX(stdout, usrCert);
         fprintf(stdout, "Subject:");
         p = X509_NAME_oneline(X509_get_subject_name(usrCert), NULL, 0);
         fprintf(stdout, "%s/n", p);
         
         fprintf(stdout, "Issuer:");
         p = X509_NAME_oneline(X509_get_issuer_name(usrCert), NULL, 0);
         fprintf(stdout, "%s/n", p);
         
         fprintf(stdout, "Not Before:");
         UTCTIME_print(buf, X509_get_notBefore(usrCert));
         fprintf(stdout, "%s/n", buf);
         
         fprintf(stdout, "Not After:");
         UTCTIME_print(buf, X509_get_notAfter(usrCert));
         fprintf(stdout, "%s/n", buf);
         //X509_print_fp(stdout, usrCert);   //add by slz token by openssl
         
         //        PEM_write_X509(<#FILE *fp#>, <#X509 *x#>)
     }
     
     if (ca && sk_num(ca))
     {
         fprintf(stdout, "***Other Certificates***/n");
         for (int i = 0; i < sk_X509_num(ca); i++)
         PEM_write_X509_AUX(stdout, sk_X509_value(ca, i));
     }
   
     
     
        
        
}
    static const char *mon[12]=
    {
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
    };
    
    /* 转换时间并存储到一个缓存区中 */
    
    int UTCTIME_print(char buf[], ASN1_UTCTIME *tm)
    {
        char *v;
        int gmt=0;
        int i;
        int y=0,M=0,d=0,h=0,m=0,s=0;
        
        i=tm->length;
        v=(char *)tm->data;
        
        if (i < 10) fprintf(stderr, "Bad time value/n");
        if (v[i-1] == 'Z') gmt=1;
        for (i=0; i<10; i++)
        if ((v[i] > '9') || (v[i] < '0')) fprintf(stderr, "Bad time value/n");
        y= (v[0]-'0')*10+(v[1]-'0');
        if (y < 50) y+=100;
        M= (v[2]-'0')*10+(v[3]-'0');
        if ((M > 12) || (M < 1)) fprintf(stderr, "Bad time value/n");
        d= (v[4]-'0')*10+(v[5]-'0');
        h= (v[6]-'0')*10+(v[7]-'0');
        m= (v[8]-'0')*10+(v[9]-'0');
        if (i >=12 &&
            (v[10] >= '0') && (v[10] <= '9') &&
            (v[11] >= '0') && (v[11] <= '9'))
        s= (v[10]-'0')*10+(v[11]-'0');
        
        sprintf(buf, "%s %2d %02d:%02d:%02d %d%s", mon[M-1], d, h, m, s, y+1900, (gmt)?" GMT":"");
        return(0);
    }
    
-(int) p12
    {
        return 0;
    }
  
    
    
    
    
@end
