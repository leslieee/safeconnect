//
//  FOXSystemTool.m
//  防火墙管理
//
//  Created by 陈宇平 on 16/3/31.
//  Copyright © 2016年 陈宇平. All rights reserved.
//

#import "FOXSystemTool.h"

@implementation FOXSystemTool

+(NSString *)getSystemLanguage {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
//    取得设置好的语言。。日语是ja，中文是zh_Hans
    return currentLanguage ;
}

    
    
    
@end
