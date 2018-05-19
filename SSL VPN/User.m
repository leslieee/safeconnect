//
//  User.m
//  TianjinBoHai
//
//  Created by 陈强 on 15/1/22.
//  Copyright (c) 2015年 Binky Lee. All rights reserved.
//

#import "User.h"

static NSString * const kSectionID = @"TianJinBoHai_sectionID";
static NSString * const kShippingAddress = @"TianJinBoHai_wang";
static NSString * const kGoodsName = @"TianJinBoHai_meng";
static NSString * const kGoodsPhone = @"TianJinBoHai_GoodsPhone";
static NSString * const kUserStr = @"TianJinBoHai_section";
static NSString * const kUserID = @"TianJinBoHai_userID";
static NSString * const kLastTradeID = @"TianJinBoHai_lastTradeID";
static NSString * const kTopSearch = @"TianJinBoHai_topSearch";

static NSString * const kRiskWarning = @"TianJinBoHai_RiskWarning";
static NSString * const kSelfSelectedAttention = @"TianJinBoHai_SelfSelectedAttention";
static NSString * const kDefaultNumber = @"TianJinBoHai_DefaultNumber";
static NSString * const kAKeyOrder = @"TianJinBoHai_AKeyOrder";

static NSString * const kATPSessionID = @"TianJinBoHai_ATPSessionID";
static NSString * const kATPCookie = @"TianJinBoHai_ATPCookie";
static NSString * const kPhone = @"YaoNowPhone";
static NSString * const kBalance = @"YaoNowBalance";
static NSString * const kDeviceToken = @"YaoNowDeviceToken";
static NSString * const kATPUserID = @"TianJinBoHai_ATPUserID";
static NSString * const kAvailableCredit = @"YaoNowAvailableCredit";
static NSString * const kUserId = @"TianJinBoHai_UserId";
static BOOL isShowReLogin;
@implementation User

+ (User*)sharedInstanced{
    static User *_sharedInstanced = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstanced = [[User alloc] init];
    });
    return _sharedInstanced;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _isLogin = NO;
        _isFirst = NO;
    }
    return self;
}

- (void) setIsReLogin:(BOOL)login{
    isShowReLogin = login;
}

- (BOOL) isReLogin{
    return isShowReLogin;
}

-(void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
}

- (void) setSectionID:(NSString *)sectionID{
    if (!sectionID) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kSectionID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localSectionID = [[NSUserDefaults standardUserDefaults] objectForKey:kSectionID];
    
    if ([localSectionID isEqualToString:sectionID]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:sectionID forKey:kSectionID];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (NSString*)sectionID{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kSectionID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSectionID];
}

-(NSMutableArray *)topSearchArray
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kTopSearch:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kTopSearch];
}

-(void)setTopSearchArray:(NSMutableArray *)topSearchArray
{
    if (!topSearchArray) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kTopSearch];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSMutableArray * localUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kTopSearch];
    if (localUserID == topSearchArray) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:topSearchArray forKey:kTopSearch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)userStr
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kUserStr:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kUserStr];
}

-(void)setUserStr:(NSString *)userStr
{
    if (!userStr) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kUserStr];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kUserStr];
    if ([localUserID isEqualToString:userStr]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userStr forKey:kUserStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSString *)autoConnect
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kUserStr:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kUserStr];
}

-(void)setAutoConnect:(NSString *)userStr
{
    if (!userStr) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kUserStr];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kUserStr];
    if ([localUserID isEqualToString:userStr]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userStr forKey:kUserStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSString *)recodeLog
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kUserID:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kUserID];
}

-(void)setRecodeLog:(NSString *)userStr
{
    if (!userStr) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kUserID];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kUserID];
    if ([localUserID isEqualToString:userStr]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userStr forKey:kUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSString *)reConnect
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kAvailableCredit:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kAvailableCredit];
}

-(void)setReConnect:(NSString *)userStr
{
    if (!userStr) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kAvailableCredit];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kAvailableCredit];
    if ([localUserID isEqualToString:userStr]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userStr forKey:kAvailableCredit];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) setCApassWord:(NSString *)userID{
    if (!userID) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];
    if ([localUserID isEqualToString: userID]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)CApassWord{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kUserID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];
}

- (void) setLastTradeID:(NSString *)lastTradeID{
    if (!lastTradeID) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLastTradeID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localLastTradeID = [[NSUserDefaults standardUserDefaults] objectForKey:kLastTradeID];
    if ([localLastTradeID isEqualToString:lastTradeID]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:lastTradeID forKey:kLastTradeID];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (NSString*)lastTradeID{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLastTradeID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastTradeID];
}

- (void) setDefaultNumber:(NSInteger)defaultNumber{
    
    NSInteger localDefaultNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultNumber] integerValue];
    if (localDefaultNumber == defaultNumber) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:defaultNumber] forKey:kDefaultNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)defaultNumber{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kDefaultNumber:@(1)}];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultNumber] integerValue];
}

- (void) setRiskWarning:(BOOL)riskWarning{

    [[NSUserDefaults standardUserDefaults] setBool:riskWarning forKey:kRiskWarning];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)riskWarning{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kRiskWarning:@YES}];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRiskWarning];
}

- (void) setAttention:(BOOL)attention{
    [[NSUserDefaults standardUserDefaults] setBool:attention forKey:kSelfSelectedAttention];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) attention{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kSelfSelectedAttention:@NO}];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSelfSelectedAttention];
}

- (void) setAKeyOrder:(BOOL)aKeyOrder{
    [[NSUserDefaults standardUserDefaults] setBool:aKeyOrder forKey:kAKeyOrder];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) aKeyOrder{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kAKeyOrder:@NO}];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAKeyOrder];
}

- (void) setATP_sessionID:(NSString *)ATP_sessionID{
    if (!ATP_sessionID || ATP_sessionID.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPSessionID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    NSString *localATPSectionID = [[NSUserDefaults standardUserDefaults] objectForKey:kATPSessionID];
    
    if ([localATPSectionID isEqualToString:ATP_sessionID]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:ATP_sessionID forKey:kATPSessionID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)ATP_sessionID{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kATPSessionID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kATPSessionID];
}

-(NSString *)userid
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kUserID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];
}

-(void)setUseriD:(NSString *)useriD
{
    if (!useriD || useriD.length == 0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kUserID];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localAtp_Cookie = [[NSUserDefaults standardUserDefaults]objectForKey:kUserID];
    if ([localAtp_Cookie isEqualToString:useriD]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:useriD forKey:kUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setPhone:(NSString *)phone
{
    if (!phone || phone.length == 0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kPhone];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localAtp_Cookie = [[NSUserDefaults standardUserDefaults]objectForKey:kPhone];
    if ([localAtp_Cookie isEqualToString:phone]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:phone forKey:kPhone];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setBalance:(NSString *)balance
{
    if (!balance || balance.length == 0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kBalance];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localAtp_Cookie = [[NSUserDefaults standardUserDefaults]objectForKey:kBalance];
    if ([localAtp_Cookie isEqualToString:balance]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:balance forKey:kBalance];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setAvailableCredit:(NSString *)availableCredit
{
    if (!availableCredit || availableCredit.length == 0)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:kAvailableCredit];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    NSString * localAtp_Cookie = [[NSUserDefaults standardUserDefaults]objectForKey:kAvailableCredit];
    if ([localAtp_Cookie isEqualToString:availableCredit]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:availableCredit forKey:kAvailableCredit];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAcessToken:(NSString *)accessToken{
    if (!accessToken || accessToken.length == 0) {
       [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPCookie];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localATP_Cookie = [[NSUserDefaults standardUserDefaults] objectForKey:kATPCookie];
    
    if ([localATP_Cookie isEqualToString:accessToken]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kATPCookie];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)ATP_acessToken{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kATPCookie:@""}];
    NSLog(@"ATP_cookie %@", [[NSUserDefaults standardUserDefaults] objectForKey:kATPCookie]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:kATPCookie];
}

-(NSString *)phone
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kPhone:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kPhone];
}

-(NSString *)availableCredit
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kAvailableCredit:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kAvailableCredit];
}

-(NSString *)balance
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kBalance:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kBalance];
}

-(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{kDeviceToken:@""}];
    return [[NSUserDefaults standardUserDefaults]objectForKey:kDeviceToken];
}

-(void)setDeviceToken:(NSString *)deviceToken
{
    if (!deviceToken || deviceToken.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kDeviceToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localATP_UserID = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    
    if ([localATP_UserID isEqualToString:deviceToken]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setATP_UserID:(NSString *)ATP_UserID{
    if (!ATP_UserID || ATP_UserID.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPUserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSString *localATP_UserID = [[NSUserDefaults standardUserDefaults] objectForKey:kATPUserID];
    
    if ([localATP_UserID isEqualToString:ATP_UserID]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:ATP_UserID forKey:kATPUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)ATP_UserID{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kATPUserID:@""}];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kATPUserID];
}

- (void) clearATP{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPUserID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPSessionID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kATPCookie];
}

- (void)writeToFile:( NSString* )content
{
       NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePackageName = [userPaths objectAtIndex:0];
    NSString* fileNamePackageRes = [[NSString alloc] initWithFormat:@"%@/%@",filePackageName,@"log.txt"];
    NSString* strLogData = [[NSString alloc]initWithFormat:@"%@",content];
    [strLogData writeToFile:fileNamePackageRes atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    
    _filePath = [[NSString alloc ]initWithString:fileNamePackageRes];
   
 
}

- (NSString*)readFile
{
    
    if (_filePath == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:_filePath];
    
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    if (error == nil) {
        NSLog(@"%@",str);
        
        return str;
    }
    else{
        NSLog(@"%@",[error localizedDescription]);
        return [error localizedDescription];
    }
    
    return  str;
    
}

- (BOOL)cancelContent{
    
    NSFileManager *fileMger = [NSFileManager defaultManager];
    
    //如果文件路径存在的话
    BOOL bRet = [fileMger fileExistsAtPath:_filePath];
    
    if (bRet) {
        
        NSError *err;
        
     return   [fileMger removeItemAtPath:_filePath error:&err];
    
    }
    return NO;
    
}


@end
