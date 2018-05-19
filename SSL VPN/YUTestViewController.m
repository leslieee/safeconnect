//
//  YUTestViewController.m
//  YUFoldingTableViewDemo
//
//  Created by administrator on 16/8/25.
//  Copyright © 2016年 xuanYuLin. All rights reserved.
//

#import "YUTestViewController.h"
#import "AddHistoryCell.h"
#import "ZJFMDBHandle.h"
#import "OptionCell.h"
#import "Config.h"
#import "ZJModel.h"

@interface YUTestViewController () <YUFoldingTableViewDelegate>

@property (nonatomic, weak) YUFoldingTableView *foldingTableView;

@property (nonatomic, strong) NSMutableArray *personArr;
@end

@implementation YUTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.arrowPosition = 0;
    self.personArr = [[ZJFMDBHandle manager]
                          selectAllPersonFromPersonTable:[ZJModel class]];
    
   
    
////    //自定义返回按钮
//    UIImage *backButtonImage = [[UIImage imageNamed:@""] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];

    [self setupFoldingTableView];
}

// 创建tableView
- (void)setupFoldingTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    YUFoldingTableView *foldingTableView = [[YUFoldingTableView alloc] initWithFrame:CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height-90)];
    _foldingTableView = foldingTableView;

    
    foldingTableView.layer.masksToBounds = YES;
    [_foldingTableView registerNib:[UINib nibWithNibName:@"AddHistoryCell" bundle:nil] forCellReuseIdentifier:@"AddHistoryCell"];
    
    [_foldingTableView registerNib:[UINib nibWithNibName:@"OptionCell" bundle:nil] forCellReuseIdentifier:@"OptionCell"];
    
    
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 30)];
//    
//    titleLabel.backgroundColor =getColor(@"BFDCF5");

    
    
    
////      titleLabel.textColor = [;
//     titleLabel.textAlignment = UITextAlignmentCenter;
//    [self.view addSubview:titleLabel];
    [self.view addSubview:foldingTableView];
    self.view.backgroundColor =getColor(@"EAEAEA");
    foldingTableView.foldingDelegate = self;
}

#pragma mark - YUFoldingTableViewDelegate / required（必须实现的代理）
// 返回箭头的位置
- (YUFoldingSectionHeaderArrowPosition)perferedArrowPositionForYUFoldingTableView:(YUFoldingTableView *)yuTableView
{
    // 没有赋值，默认箭头在左
    return self.arrowPosition ? :YUFoldingSectionHeaderArrowPositionRight;
}
- (NSInteger )numberOfSectionForYUFoldingTableView:(YUFoldingTableView *)yuTableView
{
    return self.personArr.count;
}
- (NSInteger )yuFoldingTableView:(YUFoldingTableView *)yuTableView numberOfRowsInSection:(NSInteger )section
{
    return 3;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForHeaderInSection:(NSInteger )section
{
    return 50;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
              return 30;
            break;
            
        case 1:
              return 30;
            break;
        case 2:
            
              return 50;
            break;
        default:
            break;
    }
  
    return 0;
    
    
}
- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary * personDic = [NSDictionary dictionaryWithDictionary:self.personArr[section]];
    
    return personDic[@"connectName"];
}
- (UITableViewCell *)yuFoldingTableView:(YUFoldingTableView *)yuTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        static NSString *cellID = @"OptionCell";
        OptionCell *cell = [yuTableView dequeueReusableCellWithIdentifier:cellID];
        
        cell.deletConnect = ^(OptionCell* cell){
           NSIndexPath *deletIndexPath = [yuTableView indexPathForCell:cell];
        
            
            [yuTableView.statusArray  removeObjectAtIndex:deletIndexPath.section];
            
            NSDictionary * model =  [self.personArr objectAtIndex:deletIndexPath.section];
            
            [[ZJFMDBHandle manager] deleteModel:model[@"connectName"]];
            [self.personArr removeObjectAtIndex:indexPath.section];
            [self.foldingTableView reloadData];
//
            
        };
        cell.selectConnect = ^(OptionCell* cell){
         
            NSIndexPath *selectIndexPath = [yuTableView indexPathForCell:cell];
            
            
            NSDictionary * model =  [self.personArr objectAtIndex:selectIndexPath.section];
            if (self.selectConnectBlock != nil) {
                
                self.selectConnectBlock(model);
            }
            
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
            
            
        };
       
          return cell;
    }else{
    static NSString *cellID = @"AddHistoryCell";
    AddHistoryCell *cell = [yuTableView dequeueReusableCellWithIdentifier:cellID];
        NSDictionary * personDic = [NSDictionary dictionaryWithDictionary:self.personArr[indexPath.section]];
        
    

        
        if (indexPath.row == 0) {
            
            
            cell.titleLable.text =NSLocalizedString(@"connectlist_serverip", @"");
            
             cell.contentLable.text =personDic[@"serverIP"];
        }else{
            cell.titleLable.text =NSLocalizedString(@"connectlist_username", @"");
               cell.contentLable.text=  personDic[@"userName"];
        }
        
          return cell;
    }
    

    return nil;
}
- (void )yuFoldingTableView:(YUFoldingTableView *)yuTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [yuTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
  
    
}

#pragma mark - YUFoldingTableViewDelegate / optional （可选择实现的）

- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView descriptionForHeaderInSection:(NSInteger )section
{
    return @"";
}


@end
