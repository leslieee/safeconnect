//
//  User.h
//  TianjinBoHai
//
//  Created by 陈强 on 15/1/22.
//  Copyright (c) 2015年 Binky Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
+ (User*)sharedInstanced;
@property (nonatomic, strong, readonly) NSString *sectionID;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *lastTradeID;

@property (nonatomic, strong, readonly) NSString *ATP_sessionID;
@property (nonatomic, strong, readonly) NSString *ATP_acessToken;
@property (nonatomic, strong, readonly) NSString *ATP_UserID;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, strong)NSString * phone;
@property (nonatomic, strong)NSString * availableCredit;
@property (nonatomic, strong)NSString * balance;
@property (nonatomic, strong)NSString * userid;
@property (nonatomic, strong)NSString * userStr;
@property (nonatomic, strong)NSString * deviceToken;
@property (nonatomic, strong)NSString * filePath;
/**
 *  热门搜索历史记录数组
 */
@property (nonatomic, strong)NSMutableArray * topSearchArray;
/**
 *  默认手数
 */
@property (nonatomic, assign, readonly) NSInteger defaultNumber;
/**
 *  风险警告
 */
@property (nonatomic, assign, readonly) BOOL riskWarning;
/**
 *  关注自选
 */
@property (nonatomic, assign, readonly) BOOL attention;
/**
 *  一键下单
 */
@property (nonatomic, assign, readonly) BOOL aKeyOrder;
@property (nonatomic, strong)NSString * autoConnect;
@property (nonatomic, strong)NSString * reConnect;
  @property (nonatomic, strong)NSString * CApassWord;
@property (nonatomic, strong)NSString *recodeLog;
@property (nonatomic, strong)NSString *logMessage;
- (void) setSectionID:(NSString *)sectionID;
- (void) setUserID:(NSString *)userID;
- (void) setLastTradeID:(NSString *)lastTradeID;
- (void) setRiskWarning:(BOOL)riskWarning;
- (void) setAttention:(BOOL)attention;
- (void) setDefaultNumber:(NSInteger)defaultNumber;
- (void) setAKeyOrder:(BOOL)aKeyOrder;
- (void) setAcessToken:(NSString *)accessToken;
- (void) setATP_sessionID:(NSString *)ATP_sessionID;
- (void) setATP_UserID:(NSString *)ATP_UserID;
- (void) clearATP;
-(void)setPhone:(NSString *)phone;
-(void)setAvailableCredit:(NSString *)availableCredit;
-(void)setBalance:(NSString *)balance;
-(void)setUseriD:(NSString *)useriD;
- (void) setIsReLogin:(BOOL)login;
-(void)setIsFirst:(BOOL)isFirst;
-(void)setUserStr:(NSString *)userStr;
-(void)setDeviceToken:(NSString *)deviceToken;
-(void)setTopSearchArray:(NSMutableArray *)topSearchArray;
- (BOOL) isReLogin;
- (void)writeToFile:( NSString* )content;

- (NSString*)readFile;
- (BOOL)cancelContent;
@end
