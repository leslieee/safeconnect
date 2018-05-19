//
//  AboutViewController.m
//  SSLVPN
//
//  Created by 陈强 on 16/11/29.
//  Copyright © 2016年 neteye. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutHeaderView.h"
#import "WebViewController.h"

#define ZZ_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIButton *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *webAddress;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 处理区域拉伸的图片

    UIImage *img = [UIImage imageNamed:@"navigationBar736"];
    // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 190, 230) resizingMode:UIImageResizingModeStretch];

    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];

self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width,self.tableView.bounds.size.height/3.3)] ;
 
    self.tableView.tableHeaderView.backgroundColor = [UIColor grayColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.title = @"";
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.scrollEnabled = NO;
//    AboutHeaderView *head = [UINib nibWithNibName:@"AboutHeaderView" bundle:nil];
  
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"AboutHeaderView" owner:nil options:nil];
    UIView * header =  views[0];
    
    header.frame =CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height/3.3);
    
    [self.tableView.tableHeaderView addSubview:header];
    
    
//    [self  setUnderSingleWithButton:_phoneNumber];
//    
//    
//    [self setUnderSingleWithButton:_webAddress];
    
}
-(void)setUnderSingleWithButton:(UIButton*)button{
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:button.titleLabel.text];
    NSRange titleRange = {0,[title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
        [title addAttribute:NSUnderlineColorAttributeName value:[UIColor blueColor] range:(NSRange){0,[title length]}];
    [button setAttributedTitle:title
                            forState:UIControlStateNormal];
  
   }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}
#pragma mark - Table view data source
- (IBAction)webAddressDidClick:(id)sender {
    
    [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:self.webAddress.titleLabel.text]];

    
    
}
- (IBAction)phoneNumberDidClick:(id)sender {
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.phoneNumber.titleLabel.text];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];


    
    
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;}
- (IBAction)readDidClick:(id)sender {
    
    
    WebViewController * webViewVC = [[WebViewController alloc]init];
    
    
  
    [self.navigationController pushViewController:webViewVC animated:YES];

    
}


//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
////#warning Incomplete implementation, return the number of rows
//    return 0;
//}

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
