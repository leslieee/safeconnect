//
//  FileWatcher.m
//  GetLocalVideo
//
//  Created by Charles.Yao on 2016/11/11.
//  Copyright © 2016年 Charles.Yao All rights reserved.
//

#import "FileWatcher.h"
//#import "VideoModel.h"
#import <openssl/x509.h>
dispatch_queue_t fileWatcher_queue() {
    static dispatch_queue_t as_fileWatcher_queue;
    static dispatch_once_t onceToken_fileWatcher;
    dispatch_once(&onceToken_fileWatcher, ^{
        as_fileWatcher_queue = dispatch_queue_create("fileWatcher.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return as_fileWatcher_queue;
}

@interface FileWatcher ()

@property (nonatomic, strong)  dispatch_source_t source;

@property (nonatomic, strong) NSMutableArray *videoNameArr;

@property (nonatomic, assign) BOOL isConvenientFinished; //便利完成

@end

@implementation FileWatcher


static FileWatcher *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (FileWatcher *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


- (void)startManager {
    
    

    self.dataSource = [[NSMutableArray alloc] init];
    
    self.videoNameArr = [[NSMutableArray alloc] init];
    
    self.isFinishedCopy = YES;  //此标识是监听
    
    self.isConvenientFinished = YES;
    
    [self getiTunesP12];
    
    [self startMonitorFile];
    
}

- (void)stopManager {
    
    dispatch_cancel(self.source);
}

- (void)startMonitorFile {  //监听Document文件夹的变化
    
    NSURL *directoryURL = [NSURL URLWithString:[SandBoxHelper docPath]]; //添加需要监听的目录
    
    int const fd =
    open([[directoryURL path] fileSystemRepresentation], O_EVTONLY);
    if (fd < 0) {
        
        NSLog(@"Unable to open the path = %@", [directoryURL path]);
        return;
    }
    
    dispatch_source_t source =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd,
                           DISPATCH_VNODE_WRITE,
                           DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^() {
        unsigned long const type = dispatch_source_get_data(source);
        switch (type) {
            case DISPATCH_VNODE_WRITE: {
                NSLog(@"Document目录内容发生变化!!!");
                if (self.isConvenientFinished) {
                    self.isConvenientFinished = NO;
                    [self directoryDidChange];
                }
                break;
            }
            default:
                break;
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
        
    });
    
    self.source = source;
    dispatch_resume(self.source);
}

#pragma mark 检索是不是通过iTunes导入视频引起的调用
- (void)directoryDidChange {
    
    [self getiTunesP12];
}

- (void)getiTunesP12 {
    
    
   
    // 2.创建通知
    
    NSNotification *notification =[NSNotification notificationWithName:@"InfoNotification" object:nil userInfo:nil];
    
    // 3.通过 通知中心 发送 通知
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    dispatch_async(fileWatcher_queue(), ^{
        //获取沙盒里所有文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //在这里获取应用程序Documents文件夹里的文件及文件夹列表
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
        if (fileList.count > 0) {
            for (NSString *file in fileList) {
                if ([file hasSuffix:@".PFX"]||[file hasSuffix:@".p12"]) {
                    NSString *videoPath = [documentDir stringByAppendingPathComponent:file];
                    
                    ;
//                    self.filePath =videoPath;
//
//                  //                    if (! [[fileManager contentsAtPath:videoPath] isEqual: [[NSUserDefaults standardUserDefaults] valueForKey:@"caData"]]) {
           
                    
//                          [[NSUserDefaults standardUserDefaults]setObject:[fileManager contentsAtPath:videoPath] forKey:@"caData"];
//                           [fileManager removeItemAtPath:videoPath error:nil];
//                    }
//
                    NSArray *lyricArr = [[NSArray alloc]initWithArray:[videoPath componentsSeparatedByString:@"/"]];
                    
                    
                    
                    if (![self.videoNameArr containsObject:[lyricArr lastObject]]) {
                      
                        
                        [self.videoNameArr addObject:[lyricArr lastObject]];
                        //===============================循环判断是否复制完成==============================================
                        NSInteger lastSize = 0;
                        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
                        NSInteger fileSize = [[fileAttrs objectForKey:NSFileSize] intValue];
                        do {
                            lastSize = fileSize;
                            [NSThread sleepForTimeInterval:0.5];
                            self.isFinishedCopy = NO;
                            fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
                            fileSize = [[fileAttrs objectForKey:NSFileSize] intValue];
                            NSLog(@"%@文件正在复制", [lyricArr lastObject]);
                        } while (lastSize != fileSize);
                        self.isFinishedCopy = YES;
                        NSLog(@"%@文件复制完成", [lyricArr lastObject]);
                      
                        self.filePath =   [[documentDir stringByAppendingString:@"/"]stringByAppendingString:[lyricArr lastObject]];
                        
                        NSArray * list  =[[NSArray alloc]initWithArray:  [fileManager contentsOfDirectoryAtPath:documentDir error:&error]];

                        for (int i = 0;  i < list.count; i++) {
                            
                            NSString * file =   list[i];
                            
                            
                            NSString* fileP =  [[documentDir stringByAppendingString:@"/"]stringByAppendingString:file];
                            
//
                        }
                        
                        
//                        VideoModel *model = [[VideoModel alloc] init];
//                        model.videoPath = videoPath;
//                        model.videoName = [lyricArr lastObject];
//                        model.videoSize = [SandBoxHelper fileSizeForPath:videoPath];
//                        model.videoImgPath = [self saveImg:[UIImage getThumbnailImage:videoPath] withVideoMid:[NSString stringWithFormat:@"%lld", model.videoSize]];
//                        model.videoAsset = nil;
//                        [self.dataSource addObject:model];
                        ///为防止一次同时拖入多个文档，使得数据加载不全，特做一次递归处理。
                        [self directoryDidChange];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshiTunesUINotification object:nil];
                }
            }
        }
        self.isConvenientFinished = YES;
    });
}

- (void)deleteiTunesVideo:(NSArray *)array {
    
//    for (VideoModel *item in array) {
//        [self.dataSource removeObject:item];
//        [SandBoxHelper deleteFile:item.videoPath];
//        [SandBoxHelper deleteFile:item.videoImgPath];
//        [self.videoNameArr removeObject:item.videoName];
//    }
}

- (NSString *)saveImg:(UIImage *)image withVideoMid:(NSString *)videoMid{
    
    if (!image) {
        image = [UIImage imageNamed:@"posters_default_horizontal"];
    }
    if (!videoMid) {
        videoMid = [NSString uuid];
    }
    //png格式
    NSData *imagedata=UIImagePNGRepresentation(image);
    
    NSString *savedImagePath = [[SandBoxHelper iTunesVideoImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", videoMid]];
    
    [imagedata writeToFile:savedImagePath atomically:YES];
    
    return savedImagePath;
    
}
-(void)saveRootCa:(NSString*)caString{
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    //指向文件目录
    
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //创建一个目录
    
    [[NSFileManager defaultManager]   createDirectoryAtPath: [NSString stringWithFormat:@"%@/rootCa", NSHomeDirectory()] attributes:nil];
    
    // File we want to create in the documents directory我们想要创建的文件将会出现在文件目录中
    
    // Result is: /Documents/file1.txt结果为：/Documents/file1.txt
    
    NSString *filePath= [documentsDirectory
                         
                         stringByAppendingPathComponent:@"ca.crt"];
    

    NSData *data = [caString dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:filePath atomically:YES];
    
//    self.filePath = filePath;
    
}

@end
