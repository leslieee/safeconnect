//
//  WebViewController.m
//  Safe Connect
//
//  Created by 陈强 on 17/2/20.
//  Copyright © 2017年 shijia. All rights reserved.
//

#import "WebViewController.h"
#import "FOXSystemTool.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    
//    NSURL *fileURL = nil ;
//    // 应用场景:加载从服务器上下载的文件,例如pdf,或者word,图片等等文件
//    if([[FOXSystemTool getSystemLanguage] hasPrefix:@"en"]){
//     
//        fileURL = [[NSBundle mainBundle] URLForResource:@"Index" withExtension:@"html"];
//    }else{
//        fileURL = [[NSBundle mainBundle] URLForResource:@"Index" withExtension:@"html"];
//    }
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
//    
//    [self.webView loadRequest:request];
    
    
    NSURL *fileURL = nil ;
    // 应用场景:加载从服务器上下载的文件,例如pdf,或者word,图片等等文件
    if([[FOXSystemTool getSystemLanguage] hasPrefix:@"en"]){
        fileURL = [[NSBundle mainBundle] URLForResource:@"IndexEN" withExtension:@"html"];
        
    }else{
        fileURL = [[NSBundle mainBundle] URLForResource:@"Index" withExtension:@"html"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    
    [self.webView loadRequest:request];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
