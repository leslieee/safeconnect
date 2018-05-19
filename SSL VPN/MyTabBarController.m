//
//  MyTabBarController.m
//  SSLVPN
//
//  Created by 陈强 on 16/11/29.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import "MyTabBarController.h"
#import "Config.h"

@interface MyTabBarController ()

@end

@interface MyTabBarController (resetTabBarItem)
/**
 *  设置TabBarItem 选择状态时的图片
 *
 *  @param index  在TabBar上第几个
 *  @param selectedImageName 图片名，NSString类型
 */
- (void) setTabBarItemWithIndex:(NSInteger)index selectedImageName:(NSString*)selectedImageName;
/**
 *  设置TabBarItem nomal和选择状态时的图片
 *
 *  @param index             在TabBar上第几个
 *  @param nomalImageName    图片名，NSString类型
 *  @param selectedImageName 图片名，NSString类型
 */
- (void) setTabBarItemWithIndex:(NSInteger)index nomalImageName:(NSString*)nomalImageName selectedImageName:(NSString*)selectedImageName;
@end

@implementation MyTabBarController (resetTabBarItem)
- (void) setTabBarItemWithIndex:(NSInteger)index selectedImageName:(NSString*)selectedImageName{
    [self setTabBarItemWithIndex:index nomalImageName:nil selectedImageName:selectedImageName];
}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;//隐藏为YES，显示为NO
//}
- (void) setTabBarItemWithIndex:(NSInteger)index nomalImageName:(NSString*)nomalImageName selectedImageName:(NSString*)selectedImageName{
    
    UITabBarItem *item = self.tabBar.items[index];
    
//    "bottom_tab1_txt"= "连接";
//    "bottom_tab2_txt"= "资源";
//    "bottom_tab3_txt"= "设置";
//    "bottom_tab4_txt"= "关于";
    
    switch (index) {
        case 0:
           
           item.title = NSLocalizedString(@"bottom_tab1_txt", @"");
            break;
           
        case 1:
            item.title = NSLocalizedString(@"bottom_tab2_txt", @"");
            break;
        case 2:
            item.title =  item.title = NSLocalizedString(@"bottom_tab3_txt", @"");
            break;
        case 3:
            item.title = NSLocalizedString(@"bottom_tab4_txt", @"");
            break;
        default:
            break;
    }
//    if (index != 1) {
        item.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
//    }
//    else
//    {
//        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
//    }
    if (nomalImageName) {
        UIImage *imageNomal = [[UIImage imageNamed:nomalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image = imageNomal;
     
        
        
    }
    
    UIImage *imageSelected = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = imageSelected;
}
@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
//    
//    // 处理区域拉伸的图片
//    UIImageView *handleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
//    UIImage *img = [UIImage imageNamed:@"navigationBar736"];
//    // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
//    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 130, 0) resizingMode:UIImageResizingModeStretch];
//    handleImg.image = img;
//    self.navigationItem.rightBarButtonItem =nil;
//    self.navigationItem.leftBarButtonItem = nil;
//    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    //    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    //
    //    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :getColor(@"535b64")} forState:UIControlStateNormal];
    //
    //    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :getColor(@"fca61e")} forState:UIControlStateSelected];
    //
    //这部分代码在viewDidLoad方法里写
    
    
    
    [self setTabBarItemWithIndex:0 nomalImageName:@"连接" selectedImageName:@"连接选中"];
    [self setTabBarItemWithIndex:1 nomalImageName:@"监控" selectedImageName:@"监控选中"];
    [self setTabBarItemWithIndex:2 nomalImageName:@"设置" selectedImageName:@"设置选中"];
    [self setTabBarItemWithIndex:3 nomalImageName:@"关于" selectedImageName:@"关于选中"];
}

@end
