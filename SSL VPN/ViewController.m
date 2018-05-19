//
//  ViewController.m
//  testTableViewCellEdit
//
//  Created by yulingsong on 16/1/8.
//  Copyright © 2016年 yulingsong. All rights reserved.
//

#import "ViewController.h"
#import "TestTableViewCell.h"
#import "Config.h"
#import "FileWatcher.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UITableView *m_tableview;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation ViewController
@synthesize m_tableview;
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
          }
    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self createTableView];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InfoNotificationAction:) name:@"InfoNotification" object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InfoNotification" object:nil];
}
- (void)InfoNotificationAction:(NSNotification *)notification{
  
  
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //resultString 是返回的数据
          _dataArr =  [self getFileList];
          [self  filterFile:_dataArr];
          [self.m_tableview reloadData];
        
    });
  
    
}
-(NSMutableArray *)filterFile:(NSMutableArray * )fileList{
    
    
    NSMutableArray * files = [[NSMutableArray alloc]init];
       [fileList enumerateObjectsUsingBlock:^(id file, NSUInteger idx, BOOL *stop) {
           NSLog(@"sss%lu", (unsigned long)fileList.count);
           if (!([file containsString:@".PFX"]||[file containsString:@".p12"]||[file containsString:@".P12"])) {
               [files addObject:file];
               
           }
        }];
    
    [fileList removeObjectsInArray:files];
    
    return fileList;
}

-(NSMutableArray*)getFileList{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    
    NSMutableArray * list  =[[NSMutableArray alloc]initWithArray:  [fileManager contentsOfDirectoryAtPath:documentDir error:nil]];
    return list;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
 
    _dataArr =  [self getFileList];
    
    _dataArr =  [self  filterFile:_dataArr];
    
    
}

-(void)createTableView
{
    if (!m_tableview)
    {
        self.m_tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
        [self.view addSubview:m_tableview];
    }
    [m_tableview setScrollEnabled:YES];
    [m_tableview setDelegate:self];
    [m_tableview setDataSource:self];
    [m_tableview setShowsVerticalScrollIndicator:NO];
    [m_tableview setUserInteractionEnabled:YES];
    [m_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier:%d",(int)indexPath.row];
    TestTableViewCell *cell = (TestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[TestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.m_back setHidden:NO];
    [cell.m_back setFrame:CGRectMake(10, 2,    [UIScreen mainScreen].bounds.size.width -20
, 30)];
    cell.m_back.backgroundColor = getColor(@"BEDDF6");

//   [cell.m_back setBackgroundColor getColor(@"BEDDF6")];
    [cell.m_back.layer setCornerRadius:5];
//
    [cell.m_button setHidden:NO];
    cell.m_button.font =  [UIFont systemFontOfSize:15] ;
    [cell.m_button setFrame:CGRectMake(20, 0, 80, 30)];
    [cell.m_button setText:[NSString stringWithFormat:@"文件名称："]];
    [cell.m_button setTextAlignment:NSTextAlignmentLeft];


    [cell.m_label setHidden:NO];
    cell.m_label.font =  [UIFont systemFontOfSize:15] ;
    [cell.m_label setFrame:CGRectMake(100, 0, 150, 30)];
    NSNumber *num = self.dataArr[indexPath.row];
    [cell.m_label setText:[NSString stringWithFormat:@"%@",num]];
    [cell.m_label setTextAlignment:NSTextAlignmentLeft];
    
    [cell.m_imageView setHidden:NO];
    [cell.m_imageView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -60, 5, 15, 18)];
    cell.m_imageView.image = [UIImage imageNamed:@"发放证书"];
 
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 34;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (indexPath.row == 0) {
//         [self alertWithTitle:NSLocalizedString(@"general_remind", @"") msg:NSLocalizedString(@"Do_not_delete", @"")];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//        return;
//    }
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {   NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString * file =   _dataArr[indexPath.row];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        
        NSString* fileP =  [[documentDir stringByAppendingString:@"/"]stringByAppendingString:file];
        [fileManager removeItemAtPath:fileP error:nil];
        
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
       }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{


    return @"删除";
}

//当滚动视图发生位移，就会进入下方代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UIPageControl *pageControl = (UIPageControl *)[self.view viewWithTag:1000];

    CGPoint point = scrollView.contentOffset;

    NSInteger index = round(point.x/scrollView.frame.size.width);

    pageControl.currentPage = index;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [NSThread sleepForTimeInterval:0.3f];
    
    NSString * fileName =  _dataArr[indexPath.row];
//    if (![fileName containsString:@".PFX"]) {
//        
//          [self alertWithTitle:NSLocalizedString(@"general_remind", @"") msg:NSLocalizedString(@"please_Input_PFX", @"")];
//        
//          [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        }else{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"caPassWord"];
    
    [FileWatcher shared].filePath = [[documentDir stringByAppendingString:@"/"]stringByAppendingString:_dataArr[indexPath.row]];
   [self.navigationController popViewControllerAnimated:YES];
//    }
}



- (void)alertWithTitle:(NSString *)title  msg:(NSString *)msg
{
    if ( msg)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"general_ok", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
}


@end
