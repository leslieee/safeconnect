//
//  WNBLL.m
//  WantNow
//
//  Created by shenxu on 15/8/6.
//  Copyright (c) 2015年 Blue Mobi. All rights reserved.
//
#import "NSString+Json.h"
#import "WNBLL.h"
#import "AFAppDotNetAPIClient.h"

@implementation WNBLL

//返回网络请求结果的接口
+ (NSURLSessionDataTask *)paramerstringUrl:(NSString *)url  paramers:(id)paramers  showHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(NSInteger resultCode,NSString *errorMessage, NSError *error))block{
    
    return [self bodyStringUrl:url paramers:paramers andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error){
        if(!error){
            if (block) {
                NSLog(@"code:%@",[[JSON valueForKey:@"verificationCode"]valueForKey:@"verificationcode"]);
                
                block([[JSON valueForKey:@"resultCode"]integerValue],[JSON valueForKey:@"errorMessage"],nil);
            }
        }else{
            block(0,nil,error);
        }
    }];
}
//网络请求基础
+ (NSURLSessionDataTask *)bodyStringUrl:(NSString *)url paramers:(id)paramers andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id JSON, NSError *error))block{
    
    MBProgressHUD *HUD;
    
    if (view) {
        HUD  = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.userInteractionEnabled = YES;
    }
    return [[AFAppDotNetAPIClient sharedClient]POST:url parameters:paramers success:^(NSURLSessionDataTask * __unused task, id JSON){
        
        
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(JSON,nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error){
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(nil,error);
        }
    }];
}

//网络请求基础（带cookie）
+ (NSURLSessionDataTask *)bodyStringUrl:(NSString *)url paramers:(id)paramers andNSCookieInfo:(NSDictionary *)dictCookie andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id JSON, NSError *error))block{
    
    MBProgressHUD *HUD;
    
    if (view) {
        HUD  = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.userInteractionEnabled = YES;
    }
    
    
    AFHTTPSessionManager *manager =[AFAppDotNetAPIClient sharedClient];
    //此处必须默认为yes
    [manager.requestSerializer setHTTPShouldHandleCookies:YES];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@=%@",@"usertoken",@"57386290b42bd82cee08dd25d5adff5a146ea691"] forHTTPHeaderField:@"Cookie"];
    
    return [manager POST:url parameters:paramers success:^(NSURLSessionDataTask * __unused task, id JSON){
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(JSON,nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error){
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(nil,error);
        }
    }];
    
}
//上传视频文件
-(NSURLSessionDataTask *)updateLoadPicDataForBaseURL:(NSString *)baseUrl paramers:(id)parameter
                                     andFileNameData:(NSData *)data andshowHUDInView:(UIView *)view andNSDictionary:(NSDictionary *)Info  resultPostsWithBlock:(void (^)(id responseObject, NSError *error))block{
    NSMutableURLRequest *request =
    [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"//请求方法为post
                                                               URLString:baseUrl//上传文件URL
                                                              parameters:parameter//上传的其他参数
                                               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)//设置请求体
     {
         [formData appendPartWithFileData:data//音乐媒体文件的data对象
                                     name:@"multipartFile"//与数据关联的参数名称，不能为nil
                                 fileName:@"fileName.mp4"//上传的文件名，不能为nil
                                 mimeType:@"audio/mp4"];//MIME类型(例如：图片为image/jpeg.) 可以参照 http://www.iana.org/assignments/media-types/. ，不能为nil
     } error:nil];
    
    return   [self updateLoadDataForRequest:request andShowHUDInView:view success:^(NSURLSessionDataTask * __unused task, id responseObject){
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        if (block) {
            block(nil,error);
        }
    }];
}
//上传图片
-(NSURLSessionDataTask *)updateLoadPicDataForBaseURL:(NSString *)baseUrl paramers:(id)parameter andImageArray:(NSArray *)imageArray andshowHUDInView:(UIView *)view  resultPostsWithBlock:(void (^)(id responseObject, NSError *error))block{
    
    MBProgressHUD *HUD;
    
    if (view) {
        HUD  = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.userInteractionEnabled = YES;
    }
    
    NSString *stringUrl = [[NSURL URLWithString:baseUrl relativeToURL:[AFAppDotNetAPIClient sharedClient].baseURL] absoluteString];
    
    
    NSString *stringJson = [NSString jsonStringWithObject:parameter];
    
    NSMutableDictionary *parameteres = (NSMutableDictionary *)@{@"data":stringJson
                                                                };
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:stringUrl parameters:parameteres constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0 ; i < [imageArray count]; i ++) {
            UIImage *image = imageArray[i];
            NSData *data = data = UIImageJPEGRepresentation(image, 0.05);
            [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"file%d",i+1] fileName:[NSString stringWithFormat:@"filename%d.jpg",i+1] mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    return   [self updateLoadDataForRequest:request andShowHUDInView:view success:^(NSURLSessionDataTask * __unused task, id responseObject){
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (block) {
            block(nil,error);
        }
    }];
}
//上传文件基础类库
-(NSURLSessionDataTask *)updateLoadDataForRequest:(NSMutableURLRequest *)request andShowHUDInView:(UIView *)view success:(void (^)(NSURLSessionDataTask *task, id responseObject))success  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            if (failure) {
                failure(uploadTask, error);
            }
        } else {
            if (success) {
                success(uploadTask, responseObject);
            }
        }
        
    }];

    [uploadTask resume];
    
    return uploadTask;
    
}

//下载文件基础类库
+(NSURLSessionDownloadTask *)downLoadDataForRequestUrl:(NSString *)linkUrl andShowHUDInView:(UIView *)view success:(void (^)(NSURLSessionDownloadTask *task, id responseObject ))success  failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure{
    
    NSString *urlString  =[linkUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSProgress *progress = nil;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // 指定下载文件保存的路径
        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
        // 将下载文件保存在缓存路径中
        
        // 将下载文件保存在缓存路径中
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
        
        //NSString *path = [self launchVideoPathForURL:linkUrl];
        
        //URLWithString返回的是网络的URL,如果使用本地URL,需要注意
        NSURL *fileURL1 = [NSURL URLWithString:path];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        NSLog(@"== %@ |||| %@", fileURL1, fileURL);
        
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        NSLog(@"%@ %@", filePath, error);
        if (error) {
            if (failure) {
                failure(downloadTask, error);
            }
        } else {
            if (success) {
                success(downloadTask, filePath);
            }
        }
        
    }];
    
    [downloadTask resume];
    
    return downloadTask;
    
}

- (MBProgressHUD *)addHUDToView:(UIView *)view withHUDInfo:(NSDictionary *)HUDInfo
{
    
    MBProgressHUD   *HUD = [[MBProgressHUD alloc] initWithView:view];
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.userInteractionEnabled = YES;
    //HUD.removeFromSuperViewOnHide = YES;
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [view addSubview:HUD];
    [HUD show:YES];

    return HUD;
}

#pragma mark - 首页
//首页
+(NSURLSessionDataTask *)geRootCa:(NSString *)url  name:(NSString* )name passwd:(NSString*)passwd
andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id , NSError *))block
{
    
//    NSString *stringJson = [NSString jsonStringWithDictionary:];
//        NSDictionary *parameteres = @{@"data":stringJson};
    
    return [self bodyStringUrl:url paramers:nil andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
                if (!error) {
//                    FindAllModelBaseClass * model = [[FindAllModelBaseClass alloc]initWithDictionary:JSON];
                    if (block) {
                        block (JSON, nil);
                    }
                }
                else
                {
                    block (nil, error);
                }
            }];
}
////发现全部
//+(NSURLSessionDataTask *)findAllUrl:(NSString *)homeUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(FindAllModelBaseClass * model, NSError *error))block
//{
//    return [self bodyStringUrl:homeUrl paramers:nil andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            FindAllModelBaseClass * model = [[FindAllModelBaseClass alloc]initWithDictionary:JSON];
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block (nil, error);
//        }
//    }];
//}
////发现景点/酒店/美食
//+(NSURLSessionDataTask *)findSitesUrl:(NSString *)findSitesUrl currentPage:(NSInteger)currentPage level:(NSInteger)level andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(FindSitesModelBaseClass * model, NSError *error))block
//{
//    NSString *stringJson = [NSString jsonStringWithDictionary:@{@"currentPage":@(currentPage), @"level":@(level)}];
//    NSDictionary *parameteres = @{@"data":stringJson};
//    
//    
//    return [self bodyStringUrl:findSitesUrl paramers:parameteres andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            FindSitesModelBaseClass * model = [[FindSitesModelBaseClass alloc]initWithDictionary:JSON];
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block (nil, error);
//        }
//    }];
//}
////热门搜索
//+(NSURLSessionDataTask *)topSearchUrl:(NSString *)topSearchUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(TopSearchModelBaseClass * model, NSError *error))block
//{
//    return [self bodyStringUrl:topSearchUrl paramers:nil andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            TopSearchModelBaseClass * model = [[TopSearchModelBaseClass alloc]initWithDictionary:JSON];
//            
//            if (block) {
//                block(model, nil);
//            }
//        }
//        else
//        {
//            block (nil, error);
//        }
//    }];
//}
////关键字搜索
//+(NSURLSessionDataTask *)keywordUrl:(NSString *)keywordUrl currentPage:(NSInteger)currentPage keywords:(NSString *)keywords andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(KeywordSearchModelBaseClass * model, NSError *error))block
//{
//    NSString *stringJson = [NSString jsonStringWithDictionary:@{@"currentPage":@(currentPage), @"keywords":keywords}];
//    NSDictionary *parameteres = @{@"data":stringJson};
//    return [self bodyStringUrl:keywordUrl paramers:parameteres andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            KeywordSearchModelBaseClass * model = [[KeywordSearchModelBaseClass alloc]initWithDictionary:JSON];
//            
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block (nil, error);
//        }
//    }];
//}
////商圈搜索
//+(NSURLSessionDataTask *)businessCircleSearchUrl:(NSString *)businessCircleSearchUrl currentPage:(NSInteger)currentPage kid:(NSInteger)kid andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(BusinessCircleSearchModelBaseClass * model, NSError *error))block
//{
//    NSString *stringJson = [NSString jsonStringWithDictionary:@{@"currentPage":@(currentPage), @"id":@(kid)}];
//    NSDictionary *parameteres = @{@"data":stringJson};
//    return [self bodyStringUrl:businessCircleSearchUrl paramers:parameteres andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            BusinessCircleSearchModelBaseClass * model = [[BusinessCircleSearchModelBaseClass alloc]initWithDictionary:JSON];
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block(nil, error);
//        }
//    }];
//}
//
////查询酒店列表(酒店预订)
//
//+(NSURLSessionDataTask *)hotelListSearchUrl:(NSString *)hotelListSearchUrl longitude:(float)longitude latitude:(float)latitude currentPage:(NSInteger)currentPage keywords:(NSString*)keywords startprice:(NSInteger)startprice endprice:(NSInteger)endprice stars:(NSInteger)stars sortBy:(NSString*)sortBy sortType:(NSString*)sortType distance:(NSInteger)distance foodTypes:(NSString*)foodTypes andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(HotelListModel * model, NSError *error))block{
//    
//
//    NSString * stringJson = [NSString jsonStringWithDictionary:@{@"longitude":@(longitude), @"latitude":@(latitude),@"currentPage":@(currentPage),@"startprice":@(startprice),@"keywords":keywords,@"sortBy":sortBy,@"sortType":sortType,@"endprice":@(endprice),@"stars":@(stars),@"distance":@(distance),@"foodTypes":foodTypes}];
//    NSDictionary *parameteres = @{@"data":stringJson};
//  
//    return [self bodyStringUrl:hotelListSearchUrl paramers:parameteres andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            HotelListModel * model = [[HotelListModel alloc]initWithDictionary:JSON];
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block(nil, error);
//        }
//    }];
//}
//
//
//
////酒店商户详情
//
//+(NSURLSessionDataTask *)hotelBusinessDetailsUrl:(NSString *)hotelBusinessDetailsUrl hotelID:(NSInteger)hotelID logintoken:(NSString*)logintoken foodTypes:(NSString*)foodTypes andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(OneHotelBusinessDetails * model, NSError *error))block{
//    
//    
//    NSString *stringJson = [NSString jsonStringWithDictionary:@{@"id":@(hotelID),@"logintoken":logintoken,@"foodTypes":foodTypes}];
//    NSDictionary *parameteres = @{@"data":stringJson};
//    
//    
//    return [self bodyStringUrl:hotelBusinessDetailsUrl paramers:parameteres andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            OneHotelBusinessDetails * model = [[OneHotelBusinessDetails alloc]initWithDictionary:JSON];
//            if (block) {
//                block (model, nil);
//            }
//        }
//        else
//        {
//            block(nil, error);
//        }
//    }];
//
//    
//}
//
////  酒店轮播图
//+(NSURLSessionDataTask *)hotelCycleViewSearchUrl:(NSString *)hotelCycleViewSearchUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(HCVHotelCycleViewModel * model, NSError *error))block{
//    
//    return [self bodyStringUrl:hotelCycleViewSearchUrl paramers:nil andShowHUDInView:view resultPostsWithBlock:^(id JSON, NSError *error) {
//        if (!error) {
//            HCVHotelCycleViewModel * model = [[HCVHotelCycleViewModel alloc]initWithDictionary:JSON];
//            
//            if (block) {
//                block(model, nil);
//            }
//        }
//        else
//        {
//            block (nil, error);
//        }
//    }];
//
//    
//    
//    
//}
//
//







@end
