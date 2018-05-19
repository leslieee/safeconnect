//
//  SSLLayer.h
//  SSL VPN
//
//  Created by shijia on 15/10/9.
//  Copyright © 2015年 shijia. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^SSLLayerAddMesssageBlock)(NSString*message);

@interface SSLLayer : NSObject
@property(nonatomic,strong)NSString*filePath;

@property(nonatomic,strong)NSString* rootCaPath;
@property(nonatomic,strong)NSString* keyPath;

@property (nonatomic, copy)SSLLayerAddMesssageBlock sslLayerMesssage;
-(id) init;
-(BOOL) restart:(NSDictionary*) dic;
-(BOOL) isHandShake;
-(BOOL) doHandShake;
-(NSString*) inf;
-(NSData*) encryptNSData:(NSData*) data;
-(NSData*) decryptNSData:(NSData*) data;
-(NSData*) read;
-(NSData*) readDecrypt;
-(int) write:(NSData*) data;
@end
