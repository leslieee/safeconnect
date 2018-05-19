//
//  animationView.m
//  animation
//
//  Created by lee on 2016/10/18.
//  Copyright © 2016年 lee. All rights reserved.
//

#import "animationView.h"
#import "BotomLineView.h"
#define DURATION 1.0f
#define ZZ_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@implementation animationView
{
    BOOL isend;
}
-(void)drawRect:(CGRect)rect
{
     _subtype = 0;
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = rect.size.width / 2 - 19;
    CGFloat start = - M_PI_2 + self.timeFlag * 1.1*M_PI;
    CGFloat end = -M_PI_2 + 0.45 * 2 * M_PI  + self.timeFlag * 1.1 *M_PI-1.3333;
    
//    if (isend)
//    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:0 clockwise:YES];

//    else
    [path addArcWithCenter:center radius:radius startAngle:start endAngle:end clockwise:YES];
    
    if (!self.color1) {
        self.color1 = [UIColor colorWithRed:253/255.0 green:125.0/255.0 blue:7.0/255.0 alpha:1];
    }
    [self.color1 setStroke];
    
    path.lineWidth = 3;
    
    [path stroke];

    UIBezierPath* path1 = [UIBezierPath bezierPath];
//    NSLog(@"timeflag %f",self.timeFlag);
    
    CGPoint center1 = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius1 = rect.size.width / 2 - 12;
    CGFloat start1 = - M_PI_2 + self.timeFlag * 0.8*M_PI;
    CGFloat end1 = -M_PI_2 + 0.45 * 2 * M_PI  + self.timeFlag * 0.8 *M_PI-1.3333;
  //  if (isend)
  //      [path1 addArcWithCenter:center1 radius:radius1 startAngle:0 endAngle:0 clockwise:YES];
  //  else

    [path1 addArcWithCenter:center1 radius:radius1 startAngle:start1 endAngle:end1 clockwise:YES];
    if (!self.color2) {
        self.color2 = [UIColor colorWithRed:28/255.0 green:181.0/255.0 blue:224.0/255.0 alpha:1];
    }
    [self.color2 setStroke];

    path1.lineWidth = 3;
    
    [path1 stroke];
    UIBezierPath* path2 = [UIBezierPath bezierPath];
    
    
    CGPoint center2 = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius2 = rect.size.width / 2 - 5;
    CGFloat start2 = - M_PI_2 + self.timeFlag * 0.5*M_PI;
    CGFloat end2 = -M_PI_2 + 0.45 * 2 * M_PI  + self.timeFlag * 0.5 *M_PI-1.3333;
    //if (isend)
    //    [path2 addArcWithCenter:center2 radius:radius2 startAngle:0 endAngle:0 clockwise:YES];
    //else
    [path2 addArcWithCenter:center2 radius:radius2 startAngle:start2 endAngle:end2 clockwise:YES];
    if (!self.color3) {
        self.color3 = [UIColor colorWithRed:39/255.0 green:165.0/255.0 blue:97.0/255.0 alpha:1] ;
    }
    [self.color3 setStroke];
    path2.lineWidth = 3;
    
    [path2 stroke];
    
}
static animationView* tmpview ;
+(void)showInView:(UIView *)view
{
    

    if (tmpview) {
        [tmpview stopAnimation];
        [tmpview removeFromSuperview];
        tmpview = nil;

    }
    animationView* aview = [[animationView  alloc]initWithFrame:CGRectMake(90, 90, 150, 150)];
    aview.backgroundColor = [UIColor clearColor];
    aview.timeFlag = 0;
    
    
    aview.center = view.center;
    NSArray * viewArr =  [view subviews];
        CGRect rect ;
    for (UIView* aView in viewArr) {
        
      
    
        if ([[NSString stringWithFormat:@"%@",[aView class]] isEqualToString:@"BotomLineView"]) {
              CGFloat height =    aView.frame.origin.y;
               rect  = aview.frame;
            rect.origin.y  = height +4 ;
          
            
        }
    }
    
   
    aview.frame = rect;
//    [view addSubview:aview];
    [view insertSubview:aview atIndex:1];
    
    
    
    
    [aview startAnimation];
    tmpview = aview;
}
+(void)dismiss
{
    [tmpview stopAnimation];
    [tmpview removeFromSuperview];
    tmpview = nil;
}
-(void)stopAnimation
{
    isend = YES;
    [self.timer invalidate];
    self.timer = nil;
    [self setNeedsDisplay];
}
-(void)startAnimation{
    
    isend = NO;
    [self.timer invalidate];
    self.timer = nil;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(continueAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer: self.timer forMode:NSRunLoopCommonModes];
    
    
    [self.timer fire];
    
}
#define speed 0.05f     //数值越小越慢
-(void)continueAnimation{
    self.timeFlag += speed;
    
    [self setNeedsDisplay];
    
}
+ (void)tapIndex:(NSInteger )index  view:(UIView *)view{
    
    
    AnimationType animationType = index;
    
    NSString *subtypeString;
//    
//    switch (_subtype) {
//        case 0:
//            subtypeString = kCATransitionFromLeft;
//            break;
//        case 1:
//            subtypeString = kCATransitionFromBottom;
//            break;
//        case 2:
//            subtypeString = kCATransitionFromRight;
//            break;
//        case 3:
//            subtypeString = kCATransitionFromTop;
//            break;
//        default:
//            break;
//    }
//    _subtype += 1;
//    if (_subtype > 3) {
//        _subtype = 0;
//    }
    
    
    
    
//
//            [self transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromBottom ForView:view];
//    
   
    
}



#pragma CATransition动画实现
+ (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view
{
  
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    
    //设置运动时间
    animation.duration = DURATION;
    
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        
        //设置子类
        animation.subtype = subtype;
    }
    
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    
    [view.layer addAnimation:animation forKey:@"animation"];
}



#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:DURATION animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
