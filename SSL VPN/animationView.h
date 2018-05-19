//
//  animationView.h
//  animation
//
//  Created by lee on 2016/10/18.
//  Copyright © 2016年 lee. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    Fade = 1,                   //淡入淡出
    Push,                       //推挤
    Reveal,                     //揭开
    MoveIn,                     //覆盖
    Cube,                       //立方体
    SuckEffect,                 //吮吸
    OglFlip,                    //翻转
    RippleEffect,               //波纹
    PageCurl,                   //翻页
    PageUnCurl,                 //反翻页
    CameraIrisHollowOpen,       //开镜头
    CameraIrisHollowClose,      //关镜头
    CurlDown,                   //下翻页
    CurlUp,                     //上翻页
    FlipFromLeft,               //左翻转
    FlipFromRight,              //右翻转
    
} AnimationType;
@interface animationView : UIView
@property (nonatomic, assign) CGFloat timeFlag;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) UIColor* color1;//内圆颜色
@property (nonatomic, strong) UIColor* color2;//中间颜色
@property (nonatomic, strong) UIColor* color3;//外圈颜色
@property (nonatomic, assign) int subtype;
-(void)startAnimation;//
-(void)stopAnimation;
+(void)showInView:(UIView *)view;//显示动画
+(void)dismiss;//停止动画
+ (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view;
@end
