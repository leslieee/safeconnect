//
//  SetUpViewController.m
//  SSLVPN
//
//  Created by 陈强 on 16/11/29.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import "SetUpViewController.h"
#import "Config.h"
#import <sys/utsname.h>
#import "User.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#define ZZ_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface SetUpViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *autoConnectButton;
@property (weak, nonatomic) IBOutlet UIButton *autoReconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *recodeLog;
@property(strong,nonatomic)NSString* logName;
@end

@implementation SetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"navigationBar736"];
    // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 190, 230) resizingMode:UIImageResizingModeStretch];
    
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];    //    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    //
    //    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :getColor(@"535b64")} forState:UIControlStateNormal];
    //
    //    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :getColor(@"fca61e")} forState:UIControlStateSelected];
    //
    //这部分代码在viewDidLoad方法里写

    if ([[User sharedInstanced].autoConnect isEqualToString:@"autoConnect"]) {
        [_autoConnectButton setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
        
        
    }
    
    if ([[User sharedInstanced].reConnect isEqualToString:@"reConnect"]) {
        [_autoReconnectButton setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
        
        
    }
    if ([[User sharedInstanced].recodeLog isEqualToString:@"recodeLog"]) {
        [_recodeLog setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
        
        
    }
   

    
    
//    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)] ;
    
    
//    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return  0.10;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0)] ;
    
    
    headerView.backgroundColor = getColor(@"BEDDF6");
    if (section == 0) {
        headerView.text = NSLocalizedString(@"frag3_setting", @"");
        
        
        headerView.textColor = [UIColor whiteColor];
    }else{
        headerView.text = NSLocalizedString(@"frag3_support", @"");
           headerView.textColor = [UIColor whiteColor];
    }
    
    return headerView;
}


//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    
//    
////    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
//    
//    
////    headerView.backgroundColor = [UIColor whiteColor];
//    
//    
//    
//    return headerView;
//    
//    
//    
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section == 1) {
                   [self sendMailToMe];
  
    }
    
    
    
    
    
}
//自动连接
- (IBAction)autoConnect:(id)sender {
    
    UIButton * button = (UIButton*)sender;
    
    if (button.currentBackgroundImage == nil) {
         [button setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
      
        [User sharedInstanced].autoConnect = @"autoConnect";
        
        
    }else{
         [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
  //        取消选中button
        
         [User sharedInstanced].autoConnect = @"NoautoConnect";
        
        
    }
    
 
  
    
}

//暂时放弃
//自动重连接
- (IBAction)autoReConnect:(id)sender {
  
    UIButton * button = (UIButton*)sender;
    
    if (button.currentBackgroundImage == nil) {
        [button setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
        
        //        选中button
        
         [User sharedInstanced].reConnect = @"reConnect";
        
        
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        //        取消选中button
        
        
        [User sharedInstanced].reConnect = @"noreConnect";

        
        
    }
    
    
    [self alertWithTitle:NSLocalizedString(@"general_remind", @"") msg:NSLocalizedString(@"reStart_program", @"")];

    
    
}
//记录日志
- (IBAction)recordingLog:(id)sender {
    
    UIButton * button = (UIButton*)sender;
    
    if (button.currentBackgroundImage == nil) {
        [button setBackgroundImage:[UIImage imageNamed:@"对号"] forState:UIControlStateNormal];
        
        //        选中button
        
          [User sharedInstanced].recodeLog = @"recodeLog";
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        //        取消选中button
                 [User sharedInstanced].recodeLog = @"norecodeLog";
        
      }
    
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
      
    }
    
}



- (void)sendMailToMe {

//   NSString [User sharedInstanced].filePath
    
    NSString *logData = [[NSString alloc]initWithContentsOfFile:[User sharedInstanced].filePath encoding:NSUTF8StringEncoding error:nil];
    
    
    if ( [[User sharedInstanced].recodeLog isEqualToString:@"recodeLog"])
    {
        if ( logData == nil ){
            
            
               [self alertWithTitle:NSLocalizedString(@"general_remind", @"") msg:NSLocalizedString(@"reStart_program", @"")];
            
            
            return ;
        }
            
        
        
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        mailCompose.mailComposeDelegate = self;
        if(mailCompose)
        {
            //设置代理
            [mailCompose setMailComposeDelegate:self];
            
            NSArray *toAddress = [NSArray arrayWithObject:@"1546626101@qq.com"];
//            NSArray *ccAddress = [NSArray arrayWithObject:@"17333245@qq.com"];;
            
            
            NSString * name = @"Neusoft SSL VPN iOS版本";
            NSString* versionNumber =   [[UIDevice currentDevice] systemVersion];;
            
            NSString * VersionInformation = [NSString stringWithFormat:@"版本信息:%@",versionNumber];
            
            NSString* phoneModel = [self iphoneType];
            
             NSString * Device = [NSString stringWithFormat:@"Device:%@",phoneModel];
          
            
            NSString * iponeM = [[UIDevice currentDevice] systemName];
            NSString * OS = [NSString stringWithFormat:@"OS:%@",iponeM];

     
            
            NSString * String1 =   [name stringByAppendingFormat:@"\n%@",VersionInformation];
            
            NSString * String2 =   [String1 stringByAppendingFormat:@"\n%@",Device];
            NSString * String3 =   [String2 stringByAppendingFormat:@"\n%@",OS];

            
            NSString *emailBody = [NSString stringWithFormat:@"%@",String3];
            
            
          
            
            
            //设置收件人
            [mailCompose setToRecipients:toAddress];
            //设置抄送人
//            [mailCompose setCcRecipients:ccAddress];
            //设置邮件内容
            [mailCompose setMessageBody:emailBody isHTML:NO];
            
            NSData* pData = [[NSData alloc]initWithContentsOfFile:[User sharedInstanced].filePath];
            
            
            NSLog(@"%@",[User sharedInstanced].filePath);
            //设置邮件主题
                         NSString *Log = NSLocalizedString(@"log", @"");
            [mailCompose setSubject:Log];
            //设置邮件附件{mimeType:文件格式|fileName:文件名}
            [mailCompose addAttachmentData:pData mimeType:@"txt" fileName:@"client.txt"];
            //设置邮件视图在当前视图上显示方式
            [self presentModalViewController:mailCompose animated:YES];
        }
    
        
        return;
    }else{
        
        
       [self alertWithTitle:NSLocalizedString(@"general_remind", @"") msg:NSLocalizedString(@"write_Log", @"")];
    }
    
    
    
    
}
- (NSString *)iphoneType {
    
//    需要导入头文件：
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
        
        
        
       

        msg = NSLocalizedString(@"Mail_cancel", @"");
            break;
        case MFMailComposeResultSaved:
        msg = NSLocalizedString(@"Mail_savedSuccessfully", @"");
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg =NSLocalizedString(@"Mail_sentSuccessfully", @"");
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
        msg = NSLocalizedString(@"E-mail_failed_send", @"");
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
