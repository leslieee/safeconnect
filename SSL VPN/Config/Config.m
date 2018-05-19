//
//  Config.m
//  TianjinBoHai
//
//  Created by  陈强 on 15/1/16.
//  Copyright (c) 2015年 Binky Lee. All rights reserved.
//

#import "Config.h"
@import QuartzCore;


NSString * textFieldBorderGrayColor = @"dddddd";
NSString * commonYellow = @"ffa200";
NSString * lightGrayColor = @"f8f8f8";
@implementation Config
UIColor* getColor(NSString * hexColor)
{
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
    
}

void commonRedButtonAttribute(UIButton* button){
    [button setBackgroundColor:getColor(@"cb4751")];
    [button.layer setCornerRadius:5];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
}
void commonYellowButtonAttribute(UIButton* button){
    [button setBackgroundColor:getColor(@"ffa200")];
    [button.layer setCornerRadius:5];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
}
void commonGrayViewAttribute(UIView* view){
    [view setBackgroundColor:getColor(@"f8f8f8")];
}

@end
