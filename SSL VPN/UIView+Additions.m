//
//  UIView+Additions.m
//  touchTest
//
//  Created by mr.song on 15/5/21.
//  Copyright (c) 2015年 mr.song. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)
-(UIViewController *)viewcontroller{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }else{
            next = [next nextResponder];
        }
    } while (next != nil);
    return nil;
}
@end
