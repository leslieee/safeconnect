//
//  WNBLL.h
//  WantNow
//
//  Created by shenxu on 15/8/6.
//  Copyright (c) 2015年 Blue Mobi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

#pragma mark - 网络请求
@interface WNBLL : NSObject <MBProgressHUDDelegate>
/**
 *  网络请求基础类库
 *
 *  @param url      接口请求地址
 *  @param paramers 字典类型集合
 *  @param view     view
 *  @param block    块对象
 *
 *  @return
 */
+ (NSURLSessionDataTask *)bodyStringUrl:(NSString *)url paramers:(id)paramers  andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id JSON, NSError *error))block;

/**
 *  网络请求基础类库(带cookie)
 *
 *  @param url      接口请求地址
 *  @param paramers 字典类型集合
 *  @param dictCookie cookie字典
 *  @param view     view
 *  @param block    块对象
 *
 *  @return
 */
+ (NSURLSessionDataTask *)bodyStringUrl:(NSString *)url paramers:(id)paramers andNSCookieInfo:(NSDictionary *)dictCookie andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id JSON, NSError *error))block;
/**
 *  上传图片
 *
 *  @param url            接口请求地址
 *  @param paramers       字典型参数集合
 *  @param block         块对象
 *
 *  @return
 */

-(NSURLSessionDataTask *)updateLoadPicDataForBaseURL:(NSString *)baseUrl paramers:(id)parameter andImageArray:(NSArray *)imageArray andshowHUDInView:(UIView *)view  resultPostsWithBlock:(void (^)(id responseObject, NSError *error))block;
/**
 *  下载文件
 *
 *  @param linkUrl 下载地址
 *  @param view    当前view
 *  @param success 块对象
 *  @param failure 块对象
 *
 *  @return
 */
+(NSURLSessionDownloadTask *)downLoadDataForRequestUrl:(NSString *)linkUrl andShowHUDInView:(UIView *)view success:(void (^)(NSURLSessionDownloadTask *task, id responseObject))success  failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;
/**
 *  首页
 *
 *  @param view  view
 *  @param block 返回值为block块
 *
 *  @return NSURLSessionDataTask类，用于扩展
// */
+(NSURLSessionDataTask *)geRootCa:(NSString *)url  name:(NSString*)name passwd:(NSString*)passwd
                 andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(id , NSError *))block;
///**
// *  发现全部
// *
// *  @param homeUrl 接口请求地址
// *  @param view    view
// *  @param block   返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)findAllUrl:(NSString *)homeUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(FindAllModelBaseClass * model, NSError *error))block;
///**
// *  发现景点/酒店/美食
// *
// *  @param findSitesUrl 接口请求地址
// *  @param currentPage  当前页
// *  @param level        商户类型：11酒店、12美食商户、14景区
// *  @param view         view
// *  @param block        返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)findSitesUrl:(NSString *)findSitesUrl currentPage:(NSInteger)currentPage level:(NSInteger)level andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(FindSitesModelBaseClass * model, NSError *error))block;
///**
// *  热门搜索
// *
// *  @param topSearchUrl 接口请求地址
// *  @param view         view
// *  @param block        返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)topSearchUrl:(NSString *)topSearchUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(TopSearchModelBaseClass * model, NSError *error))block;
///**
// *  关键字搜索
// *
// *  @param keywordUrl  接口请求地址
// *  @param currentPage 当前页
// *  @param keywords    关键字
// *  @param view        view
// *  @param block       返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)keywordUrl:(NSString *)keywordUrl currentPage:(NSInteger)currentPage keywords:(NSString *)keywords andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(KeywordSearchModelBaseClass * model, NSError *error))block;
///**
// *  商圈搜索
// *
// *  @param businessCircleSearchUrl 接口请求地址
// *  @param currentPage             当前页
// *  @param kid                     商圈id
// *  @param view                    view
// *  @param block                   返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)businessCircleSearchUrl:(NSString *)businessCircleSearchUrl currentPage:(NSInteger)currentPage kid:(NSInteger)kid andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(BusinessCircleSearchModelBaseClass * model, NSError *error))block;
//
///**
// *  查询酒店列表(酒店预订)
// *
// *  @param hotelListSearchUrl      接口请求地址
// *  @param longitude               用户手机位置：经度
// *  @param latitude                用户手机位置：纬度
// *  @param currentPage             不传默认为1，当前页号(从1开始)，第一次进入列表时此参数请传1，下拉刷新的时候此值+1并重新请求一次此接口
// *  @param keywords		           搜索关键字，将根据此关键字与酒店名称和酒店地址进行模糊匹配
// *  @param startprice		       价格开始区间，单位：元
// *  @param endprice	        	   价格结束区间，单位：元
// *  @param stars	               酒店星级：20五星 21四星 22 三星 23二星 24一星
// *  @param sortBy                  排序标准，可能取值null(即不传默认为综合排序)，sellNum销量，scenePrice价格，averageScore评价，distance距离
// *  @param sortType	               排序规则 不传或ASC表示升序，DESC表示降序
// *  @param distance	               与当前用户的距离 以米为单位
// *  @param view                    view
// *  @param block                   返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//
//+(NSURLSessionDataTask *)hotelListSearchUrl:(NSString *)hotelListSearchUrl longitude:(float)longitude latitude:(float)latitude currentPage:(NSInteger)currentPage keywords:(NSString*)keywords startprice:(NSInteger)startprice endprice:(NSInteger)endprice stars:(NSInteger)stars sortBy:(NSString*)sortBy sortType:(NSString*)sortType distance:(NSInteger)distance foodTypes:(NSString*)foodTypes andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(HotelListModel * model, NSError *error))block;
//
///**
// *  酒店商户详情
// *
// *  @param hotelBusinessDetailsUrl  接口请求地址
// *  @param logintoken               用户的logintoken，不传默认为未登录，未传的影响：返回值isCollected始终是0表示未收藏
// *  @param foodTypes                房间类型 140全日房，141钟点房，不传或传140,141视为查询该酒店的全部商品
// *  @param view                     view
// *  @param hotelID                  酒店id
// *  @param block                    返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//
//+(NSURLSessionDataTask *)hotelBusinessDetailsUrl:(NSString *)hotelBusinessDetailsUrl hotelID:(NSInteger)hotelID logintoken:(NSString*)logintoken foodTypes:(NSString*)foodTypes andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(OneHotelBusinessDetails * model, NSError *error))block;
//
//
///**
// *  酒店轮播图
// *
// *  @param view                     view
// *  @param block                    返回值为block块
// *
// *  @return NSURLSessionDataTask类，用于扩展
// */
//+(NSURLSessionDataTask *)hotelCycleViewSearchUrl:(NSString *)hotelCycleViewSearchUrl andShowHUDInView:(UIView *)view resultPostsWithBlock:(void (^)(HCVHotelCycleViewModel * model, NSError *error))block;
//





@end
