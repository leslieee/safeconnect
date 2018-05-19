//
//  SSLLayer.m
//  SSL VPN
//
//  Created by shijia on 15/10/9.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import "SSLLayer.h"
#import <openssl/ssl.h>
#import <openssl/x509.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
 #include <openssl/ssl.h>
 #include <openssl/err.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/pkcs12.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#import "PrAndPu.h"
#define CA_FILE                "/home/waf/keyless/test/cert/CA/cacert.pem"
 #define CLIENT_KEY            "/home/waf/keyless/test/cert/client-cert/key.pem"
 #define CLIENT_CERT         "/home/waf/keyless/test/cert/client-cert/cert.pem"
#define MAXBUF 4096
/*所有需要的参数信息都在此处以#define的形式提供*/
#define CERTF  "client.crt"  /*客户端的证书(需经CA签名)*/
#define KEYF  "client.key"   /*客户端的私钥(建议加密存储)*/
#define CACERT "ca.crt"      /*CA 的证书*/
#define PORT   1111          /*服务端的端口*/
#define SERVER_ADDR "127.0.0.1"  /*服务段的IP地址*/

#define CHK_NULL(x) if ((x)==NULL) exit (-1)
#define CHK_ERR(err,s) if ((err)==-1) { perror(s); exit(-2); }
#define CHK_SSL(err) if ((err)==-1) { ERR_print_errors_fp(stderr); exit(-3); }

@implementation SSLLayer

SSL *ssl;
SSL_CTX *ctx;
BIO *in_bio;
BIO *out_bio;
BIO *ssl_bio;

bool isHandShake=false;
NSString* strInf = @"null";
  NSString * caPassWord = @"null";
   NSData * rootCaData ;


-(NSString*) inf
{
    return strInf;
}

-(id)init
{
    if(self = [super init])
    {
        SSL_library_init();
        
        // 加载 BIO 抽像库错误信息
        ERR_load_BIO_strings();
        // 加载 SSL 抽像库错误信息
        SSL_load_error_strings();
        OpenSSL_add_all_algorithms();
    }
    return self;
}

-(BOOL) isHandShake
{
    if (SSL_is_init_finished(ssl))
    {
        
        return true;
    
    }
    else
    {
        
        
        return false;   }
}


-(NSArray*) writeTofile:(NSDictionary*) dic{
    NSMutableArray * fileArr = [NSMutableArray array];
  

   
   NSData* clientCa =  dic[@"ca"];
    
  [fileArr addObject:[self writeToLocationWithData:clientCa]];
    
    
   NSString * rootCa =   dic[@"rootCa"];
    
    [fileArr addObject:[self writeToLocationWithString:rootCa]];
    if([@"NOPASSWORD" isEqual:dic[@"caPassWord"]]){
        caPassWord = @"";
    }else{
          caPassWord =  dic[@"caPassWord"];
    }
 
    return fileArr;
    
}
-(NSString*) writeToLocationWithData:(NSData*) data{
    
    
    if ([data length]>0){
        
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        //指向文件目录
        
        NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //创建一个目录
        
        [[NSFileManager defaultManager]   createDirectoryAtPath: [NSString stringWithFormat:@"%@/myFolder", NSHomeDirectory()] attributes:nil];
        
        // File we want to create in the documents directory我们想要创建的文件将会出现在文件目录中
        
        // Result is: /Documents/file1.txt结果为：/Documents/file1.txt
        
        NSString *filePath= [documentsDirectory
                             
                             stringByAppendingPathComponent:@"file2.PFX"];
        
        [data writeToFile:filePath atomically:YES];
        
      return  filePath;
        
        
    }

    return @"";
    
}
-(NSString*) writeToLocationWithString:(NSString*) string{
    
    
    if ([string length]>0){
        
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        //指向文件目录
        
        NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //创建一个目录
        
        [[NSFileManager defaultManager]   createDirectoryAtPath: [NSString stringWithFormat:@"%@/myRootCA", NSHomeDirectory()] attributes:nil];
        
        // File we want to create in the documents directory我们想要创建的文件将会出现在文件目录中
        
        // Result is: /Documents/file1.txt结果为：/Documents/file1.txt
        
        NSString *filePath= [documentsDirectory
                             
                             stringByAppendingPathComponent:@"CA.crt"];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [data writeToFile:filePath atomically:YES];
        
        return  filePath;
        
        
    }

    
    return  nil;
    
}
-(BOOL) restart:(NSDictionary*) dic
{
    
    
  NSArray *filePaths =  [self writeTofile:dic];
    
    
    self.filePath = filePaths[0];
    
    self.rootCaPath  = filePaths[1];
  
    
    
//     创建文件管理器
    

    ctx=SSL_CTX_new(SSLv23_client_method());

    
    if ([self.filePath isEqualToString:@""]) {
//        单向
         ssl=SSL_new(ctx);
        
        if ( self.sslLayerMesssage != nil) {
        self.sslLayerMesssage(@"Only Server Verification");
          SSL_set_verify (ssl, SSL_VERIFY_NONE, NULL);
        }
    }else{
        //     双向
        
        if ( self.sslLayerMesssage != nil) {
                self.sslLayerMesssage(@"Server And client Verification");
        }
        
       
         [self BidirectionalAuthentication];
          SSL_set_verify (ssl, SSL_VERIFY_PEER, NULL);
    }
    
    //初始化BIO
    ssl_bio=BIO_new(BIO_f_ssl());
    
    in_bio = BIO_new (BIO_s_mem ());
    out_bio = BIO_new (BIO_s_mem ());
    
//    BIO_set_write_buf_size (in_bio, DEFBUF);                             // BIO_ctrl() API to increase the buffer size.
//    BIO_set_write_buf_size (out_bio, DEFBUF);
//    
                                     // Set ssl to work in client mode

    SSL_set_bio(ssl, in_bio, out_bio);
    
    SSL_set_connect_state(ssl);
    
  
    
    BIO_set_ssl(ssl_bio, ssl, BIO_NOCLOSE);
    
  

    
    isHandShake=false;
    return true;
}


- (void)ShowCerts:(SSL *)ssl
 {
      X509 *cert;
        char *line;
        cert = SSL_get_peer_certificate(ssl);
     
     
     
  
     if ( NULL == cert )
     {
    
  
         
         
//         teststrInf = [NSString stringWithFormat:@"Error: %s\n",
//                       ERR_reason_error_string( ERR_get_error() )];
//
//    
         
         if ( self.sslLayerMesssage != nil) {
             self.sslLayerMesssage([NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Error: %s\n",
                                                                                            ERR_reason_error_string( ERR_get_error() )]]);
         }
         
//         
//         teststrInf = [NSString stringWithFormat:@" err: %s\n",ERR_error_string( ERR_get_error(),
//                                                                                                        NULL )];
     }
     
     
        if (cert != NULL) {
      printf("数字证书信息:\n");
         line = X509_NAME_oneline(X509_get_subject_name(cert), 0, 0);
            
            
            
         printf("证书: %s\n", line);
            ;
            if ( self.sslLayerMesssage != nil) {
                 self.sslLayerMesssage([NSString stringWithFormat:@"%s",line]);
            }
            
       
            
         free(line);
         line = X509_NAME_oneline(X509_get_issuer_name(cert), 0, 0);
         printf("颁发者: %s\n", line);
         free(line);
         X509_free(cert);
     } else {
             printf("无证书信息！\n");
         }
     }


-(void) BidirectionalAuthentication{
   int sockfd, len;
    struct sockaddr_in dest;
    PKCS12 *p12 = NULL;
    X509 *usrCert = NULL;
    EVP_PKEY *pkey = NULL;
    STACK_OF(X509) *ca = NULL;
    BIO *bio;
    
     const char * caPassword =[caPassWord UTF8String];

    char *p;
    char buf[1024];
    
    SSLeay_add_all_algorithms();
    ERR_load_crypto_strings();
    NSString*  path = self.filePath;
    const char * a =[path UTF8String];
    
    bio = BIO_new_file(a, "rb");
    p12 = d2i_PKCS12_bio(bio, NULL); //得到p12结构
    BIO_free_all(bio);
    PKCS12_parse(p12, caPassword, &pkey, &usrCert, &ca); //得到x509结构
    PKCS12_free(p12);
    
    
//    if (!PKCS12_parse(p12, caPassword, &pkey, &usrCert, &ca))
//    {
//        
//        return ;
//    }
//    
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
        self.keyPath = pkeyFile;
        
        
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
    
   
    

    
    
//       char buffer[MAXBUF + 1];
//       SSL_CTX *ctx;
//       SSL *ssl;
//       const SSL_METHOD *method;
   
    
   
//       SSL_library_init();
    
//    ERR_load_BIO_strings();
//       SSL_load_error_strings();
//       OpenSSL_add_all_algorithms();
//       method = TLSv1_2_client_method();
//       ctx = SSL_CTX_new(method);
   
       if (!ctx) {
            printf("create ctx is failed.\n");
       }
   
   
//        const char * cipher_list = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH";
//       if (SSL_CTX_set_cipher_list(ctx, cipher_list) == 0) {
//             SSL_CTX_free(ctx);
////             printf("Failed to set cipher list: %s", cipher_list);
//        }

   
    

    
    NSString * Key =  [[NSBundle mainBundle] pathForResource:@"client" ofType:@"key"];
    NSString * cert =  [[NSBundle mainBundle] pathForResource:@"client" ofType:@"crt"];

    
    const char * caclient1 =[self.rootCaPath UTF8String];

       /*设置会话的握手方式*/
       SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT, 0);
   
//   加载CA FILE

  　
    if (SSL_CTX_load_verify_locations(ctx, caclient1, 0) != 1) {
           SSL_CTX_free(ctx);
           printf("Failed to load CA file %s", CA_FILE);
        if ( self.sslLayerMesssage != nil) {
            self.sslLayerMesssage(@"Failed to load CA file");
            
        }
        
        
       }
   if (SSL_CTX_set_default_verify_paths(ctx) != 1) {
           SSL_CTX_free(ctx);
           printf("Call to SSL_CTX_set_default_verify_paths failed");
       
       
       if ( self.sslLayerMesssage != nil) {
           self.sslLayerMesssage(@"Call to SSL_CTX_set_default_verify_paths failed");
           
       }
       }

    /*加载客户端证书*/
    
    if (SSL_CTX_use_certificate(ctx, usrCert) != 1) {
        SSL_CTX_free(ctx);
        printf("Failed to load client certificate from %s", CLIENT_KEY);
        
        if ( self.sslLayerMesssage != nil) {
            self.sslLayerMesssage(@"Failed to load client certificate");
            
        }

    }
    /*加载客户端私钥*/
    
    
    if (SSL_CTX_use_PrivateKey(ctx, pkey) != 1) {
        SSL_CTX_free(ctx);
        printf("Failed to load client private key from %s", CLIENT_KEY);
        
        
        if ( self.sslLayerMesssage != nil) {
            self.sslLayerMesssage(@"Failed to load client private key");
            
        }
    }
    /*验证私钥*/
    if (SSL_CTX_check_private_key(ctx) != 1) {
        SSL_CTX_free(ctx);
        printf("SSL_CTX_check_private_key failed");
        
        
        if ( self.sslLayerMesssage != nil) {
            self.sslLayerMesssage(@"SSL_CTX_check_private_key failed");
            
        }
    }
    
    
    
     /*加载客户端证书*/
    

//   if (SSL_CTX_use_certificate_file(ctx, cert1, SSL_FILETYPE_PEM) != 1) {
//           SSL_CTX_free(ctx);
//           printf("Failed to load client certificate from %s", CLIENT_KEY);
//       }
//   /*加载客户端私钥*/
//   if (SSL_CTX_use_PrivateKey_file(ctx, key1, SSL_FILETYPE_PEM) != 1) {
//           SSL_CTX_free(ctx);
//           printf("Failed to load client private key from %s", CLIENT_KEY);
//       }
//   /*验证私钥*/
//   if (SSL_CTX_check_private_key(ctx) != 1) {
//           SSL_CTX_free(ctx);
//           printf("SSL_CTX_check_private_key failed");
//       }
    
//SSL_CTX_use_certificate(ctx, <#X509 *x#>)
    
   /*处理握手多次*/
   SSL_CTX_set_mode(ctx, SSL_MODE_AUTO_RETRY);
//
  
//
//    bzero(&dest, sizeof(dest));
//    dest.sin_family = AF_INET;
//    dest.sin_port = htons(atoi("10442"));
//    if (inet_aton("10.3.3.86", (struct in_addr *) &dest.sin_addr.s_addr) == 0) {
//            perror("10.3.3.86");
//            exit(errno);
//        }
//   
//    if (connect(sockfd, (struct sockaddr *) &dest, sizeof(dest)) != 0) {
//            perror("Connect ");
//            exit(errno);
//        }
   
    /*创建SSL*/

    
    ssl = SSL_new(ctx);
    
    
    if (ssl == NULL) {
            printf("SSL_new error.\n");
        }
    
    
  int  ret = SSL_check_private_key (ssl);
    if (ret != 1) {
      
    }
        /*将fd添加到ssl层*/
//    SSL_set_fd(ssl, sockfd);
    
 
//   int  err =  SSL_connect(ssl);

//    if (err == -1) {
//            printf("SSL_connect fail.\n");
//            ERR_print_errors_fp(stderr);
//        } else {
    
//            printf("Connected with %s encryption\n", SSL_get_cipher(ssl));
//            teststrInf = [NSString stringWithFormat:@"Connected with %s encryption\n",SSL_get_cipher(ssl)];
    
    
            
//            //
//        }
//    

    EVP_PKEY_free(pkey);
    X509_free(usrCert);
    sk_X509_free(ca);
    
    
//    bzero(buffer, MAXBUF + 1);
//    strcpy(buffer, "from client->server");
//   
//    len = SSL_write(ssl, buffer, strlen(buffer));
//    if (len < 0) {
//            printf("消息'%s'发送失败！错误代码是%d，错误信息是'%s'\n", buffer, errno, strerror(errno));
//        } else {
//             printf("消息'%s'发送成功，共发送了%d个字节！\n", buffer, len);
//             }
//    
//    finish:
//    
//        SSL_shutdown(ssl);
//        SSL_free(ssl);
//        close(sockfd);
//        SSL_CTX_free(ctx);
    
    
}

-(NSData*) readDecrypt
{
    unsigned char buffer[4096]={};
    int ret= SSL_read(ssl, buffer, sizeof(buffer));
    if (ret>0)
    {   return [[NSData alloc] initWithBytes:buffer length:ret];    }
    else
    {return [[NSData alloc] init];}
}


-(BOOL) doHandShake
{
    if(isHandShake)
    {
        
       

        
        return true; }
    if (SSL_is_init_finished(ssl))
    {
        if (SSL_do_handshake(ssl)==0)
            
            
        {
            
            if ( self.sslLayerMesssage != nil) {
                self.sslLayerMesssage(@"SSL Handshake is init finished");
                
            }
            isHandShake=true;
        
        }
    }
     return isHandShake;
}

-(NSData*) read
{

    
    if ( self.sslLayerMesssage != nil) {
        self.sslLayerMesssage([NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Error: %s\n",
                                                                ERR_reason_error_string( ERR_get_error() )]]);
    }
    

    
   
//
    unsigned char buffer[4096]={};
    if (!SSL_is_init_finished(ssl))//未完成握手
    {
        
        
        int ret = SSL_do_handshake(ssl);
        if (ret < 0)
        {
            
            int err = SSL_get_error(ssl, ret);
            if (SSL_get_error(ssl, ret)==SSL_ERROR_WANT_READ)
            {
              

                int  read = BIO_read(out_bio, buffer, sizeof(buffer));
                long num =  SSL_get_verify_result( ssl );
                if ( X509_V_OK == num )
                {
                   
                  [self  ShowCerts:ssl];
                    
                    if ( self.sslLayerMesssage != nil) {
                        self.sslLayerMesssage([NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Error: %s\n",
                                                                                ERR_reason_error_string( ERR_get_error() )]]);
                    }
                    

                    
                }
                    
                
//
                if (read > 0)
                {  return [[NSData alloc] initWithBytes:buffer length:read]; }
            }
        }
        
    }else{
     
        
        
        if ( self.sslLayerMesssage != nil) {
            self.sslLayerMesssage(@"SSL Handshake is init finished");
            
        }
    }
    //    else//已经握手
    //    {
    //        isHandShake=true;
    //
    //        //
    //        //        int pending = BIO_ctrl_pending(out_bio);
    //        //        if (pending > 0)
    //        //        {
    //        //            int read = BIO_read(out_bio, buffer, sizeof(buffer));
    //        ////            if (read > 0)
    //        ////            {  return [[NSData alloc] initWithBytes:buffer length:read]; }
    //        //        }
    //        //??????????
    //        int pending = BIO_ctrl_pending(in_bio);
    //        if (pending > 0)
    //        {
    //            int read = SSL_read(ssl, buffer, sizeof(buffer));
    //            if (read>0)
    //            { return [[NSData alloc] initWithBytes:buffer length:read];}
    //        }
    //    }
    return [[NSData alloc] init];
}


-(int) write:(NSData*) data
{
    
   
    
    return BIO_write(in_bio, data.bytes, (int)data.length);
}


//加密
-(NSData*) encryptNSData:(NSData*) data
{
    unsigned char buffer[4096]={};
    if(![self isHandShake])
    {  return [[NSData alloc] init];  }
    if(SSL_write(ssl, data.bytes,(int)data.length) < 0)
    {  return [[NSData alloc] init];  }
    int ret = BIO_read(out_bio, buffer, sizeof(buffer));
    if (ret <= 0)
    {  return [[NSData alloc] init];  }
    return [[NSData alloc] initWithBytes:buffer length:ret];
}

//解密
-(NSData*) decryptNSData:(NSData*) data
{
    unsigned char buffer[4096]={};
    if(![self isHandShake])
    {  return [[NSData alloc] init];  }
    if(BIO_write(in_bio, data.bytes, (int)data.length))
    {   return [[NSData alloc] init];   }
    int ret = SSL_read(ssl, buffer, sizeof(buffer));
    if (ret <= 0)
    { return [[NSData alloc] init];  }
    return [[NSData alloc] initWithBytes:buffer length:ret];
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
