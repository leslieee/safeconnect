//
//  HttpRequest.m
//  AfnHttpsSSLDemo
//
//  Created by Apple on 16/1/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "HttpRequest.h"
#import "AFNetworking.h"
#import "LoginModel.h"
#import "SLSourceListModel.h"

#import "User.h"

/**
 *  是否开启https SSL 验证
 *
 *  @return YES为开启，NO为关闭
 */
#define openHttpsSSL YES
/**
 *  SSL 证书名称，仅支持cer格式。“app.bishe.com.cer”,则填“app.bishe.com”
 */
#define certificate @"adn"

@implementation HttpRequest

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    // 1.获得请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 2.申明返回的结果是text/html类型
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 3.设置超时时间为10s
    
    
    if([[User sharedInstanced].reConnect isEqualToString:@"reConnect"]) {
        
     
        mgr.requestSerializer.timeoutInterval = 1000;
    }else{
           mgr.requestSerializer.timeoutInterval = 1000;
    }
    

    
    // 加上这行代码，https ssl 验证。
    if(openHttpsSSL)
    {
        
        //后台自建证书,因为证书无效导致AFN请求被取消,此段代码用在外网测试环境
     
            AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            securityPolicy.allowInvalidCertificates = YES;
            securityPolicy.validatesDomainName = NO;
           mgr.securityPolicy = securityPolicy;
        

        
        
//        [mgr setSecurityPolicy:[self customSecurityPolicy]];
    }
    
    // 4.发送POST请求
    [mgr POST:url parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObj) {
          if (success) {
              
              
              NSString *receiveStr = [[NSString alloc]initWithData:responseObj encoding:NSUTF8StringEncoding];
              
//              字符串再生成NSData
              
              NSData * data = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
              
//              再解析
              
              NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//       NSDictionary* dic =        [self dictionaryWithContentsOfData:responseObj];
              
                   LoginModel * model = [[LoginModel alloc]initWithDictionary:jsonDict];
              
              
              success(model);
              
              
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}



+ (void)sourceListpost:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    // 1.获得请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 2.申明返回的结果是text/html类型
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 3.设置超时时间为10s
    
    
    if([[User sharedInstanced].reConnect isEqualToString:@"reConnect"]) {
        
        
        mgr.requestSerializer.timeoutInterval = 1000;
    }else{
        mgr.requestSerializer.timeoutInterval = 1000;
    }
    
    
    
    // 加上这行代码，https ssl 验证。
    if(openHttpsSSL)
    {
        
        //后台自建证书,因为证书无效导致AFN请求被取消,此段代码用在外网测试环境
        
        AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        mgr.securityPolicy = securityPolicy;
        
        
        
        
        //        [mgr setSecurityPolicy:[self customSecurityPolicy]];
    }
    
    // 4.发送POST请求
    [mgr POST:url parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObj) {
          
          if (success) {
              
              
              NSString *receiveStr = [[NSString alloc]initWithData:responseObj encoding:NSUTF8StringEncoding];
              
              //              字符串再生成NSData
              
              NSData * data = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
              
              //              再解析
              
              NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
              //       NSDictionary* dic =        [self dictionaryWithContentsOfData:responseObj];
              
              SLSourceListModel * model = [[SLSourceListModel alloc]initWithDictionary:jsonDict];
              
              
              success(model);
              
              
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}


+ (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificate ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
//
    [securityPolicy setAllowInvalidCertificates:YES];
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
//    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}
@end
