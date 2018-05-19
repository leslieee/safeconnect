//
//  ViewControllerInf1.swift
//  Safe Connect
//
//  Created by 陈强 on 16/12/27.
//  Copyright © 2016年 shijia. All rights reserved.
//

import UIKit
import UIKit
import Foundation
import NetworkExtension

let SCEENWIGHT = (UIScreen.mainScreen().bounds.size.width)


class ViewControllerInf: UITableViewController {
//    @IBOutlet weak var txtTime:UILabel!
      var ipAddress: UILabel!
     var DNS: UILabel!
var DNS1: UILabel!
    var manager:NEVPNManager?
    var session:NETunnelProviderSession?
    var timer:NSTimer?=nil
    var timeCount:Int = 0
    let timeOut:Int=60
    let dataIp="ip".dataUsingEncoding(NSUTF8StringEncoding)!
    let dataTime="time".dataUsingEncoding(NSUTF8StringEncoding)!
    let dataPacket="packet".dataUsingEncoding(NSUTF8StringEncoding)!
    let dataDNS="DNS".dataUsingEncoding(NSUTF8StringEncoding)!
    let dataDebug1="debug1".dataUsingEncoding(NSUTF8StringEncoding)!
    let pingRestart="pingRestart".dataUsingEncoding(NSUTF8StringEncoding)!
    let dataDebug2="debug2".dataUsingEncoding(NSUTF8StringEncoding)!
    var Controller = UIViewController()
    var logMessage:String = ""

    var sourceMessageArray: NSMutableArray  = []
    var ControllerLog = ViewControllerLog()

    override func viewDidLoad() {
        super.viewDidLoad()
     
     
        
      let img = UIImage.init(named: "navigationBar736")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 190, 230))
        // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
        
              self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics:UIBarMetrics(rawValue: 0)!)
        
        
//              self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navigationBar736"), forBarMetrics:UIBarMetrics(rawValue: 0)!)
        
        self.manager =  ManagerInstance.shareSingle().manager
        
         
        self.headerView()
        if self.manager != nil {
            self.session = self.manager!.connection as? NETunnelProviderSession
            
   
            
            
            
        }
        
        
    }

     func headerView() {
        
        
        let headerView =   UIView()
        headerView.frame = CGRectMake(0, 0, SCEENWIGHT, 120)
        headerView.backgroundColor = UIColor .whiteColor()
        
       let titleView =   UILabel()
       titleView.frame = CGRectMake(0, 0, SCEENWIGHT, 30)
       titleView.backgroundColor = getColor("BEDDF6")
     
    
        
        titleView.text = "frag2_connection_info".localized;
        titleView.textColor = UIColor .whiteColor()
        
        let ipLabel =   UILabel()
        ipLabel.frame = CGRectMake(20, 40, SCEENWIGHT, 30)
        ipLabel.backgroundColor = UIColor.whiteColor()
        
        
        ipLabel.text = "frag2_client_ip".localized
        

        

        ipLabel.font =  UIFont.systemFontOfSize(14)
        ipAddress =   UILabel()
        ipAddress.frame = CGRectMake(SCEENWIGHT-120,40, 100, 30)
        ipAddress.backgroundColor = UIColor.clearColor()
        ipAddress.text = ""
        
        
        ipAddress.textAlignment  = .Right
           ipAddress.font =  UIFont.systemFontOfSize(14)
        headerView.addSubview(ipLabel)
    
        headerView.addSubview(ipAddress)
          headerView.addSubview(titleView)
        
        let DNSLabel =   UILabel()
        DNSLabel.frame = CGRectMake(20, 70, SCEENWIGHT, 30)
        DNSLabel.backgroundColor = UIColor.whiteColor()
        DNSLabel.text = "frag2_dns_content".localized
        DNSLabel.font =  UIFont.systemFontOfSize(14)
        
   
        DNS =   UILabel()
        DNS.frame = CGRectMake(SCEENWIGHT-170,70, 150, 30)
        DNS.backgroundColor = UIColor.clearColor()
        DNS.text = ""
        DNS.textAlignment  = .Right
        DNS.font =  UIFont.systemFontOfSize(14)
        
        
        
        DNS1 =   UILabel()
        DNS1.frame = CGRectMake(SCEENWIGHT-170,90, 150, 30)
        DNS1.backgroundColor = UIColor.clearColor()
        DNS1.text = ""
        DNS1.textAlignment  = .Right
        DNS1.font =  UIFont.systemFontOfSize(14)
        headerView.addSubview(DNSLabel)
        headerView.addSubview(DNS)
           headerView.addSubview(DNS1)
        self.tableView.tableHeaderView = headerView

    }
    override func viewWillDisappear(animated: Bool) {
        
  
        super.viewWillDisappear(animated);
        if self.timer != nil {
            
                                self.timer!.invalidate()
                                     self.timer=nil
                            }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
     
//        let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@",,"s1","ios")
//        
 
     
        
        self.ipAddress.text = ""
        self.DNS.text  =  ""
        self.DNS1.text  =  ""
        if ManagerInstance.shareSingle().login == 1 {

            
            let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@", ManagerInstance.shareSingle().IPAddress!,self.stringFomatTransfom(ManagerInstance.shareSingle().userName! as String),stringFomatTransfom("ios"))
            
            
            HttpRequest.sourceListpost(loginUrl, params: nil, success: { json in
                
                let model =    json as! SLSourceListModel;
                
                if(model.code  ==  0){
                    var  i = 0;
                    
                    self.sourceMessageArray.setArray(model.data
                    )
                    
                    var sourceMessage: NSMutableArray  = []
                    for( i = 0 ;i < self.sourceMessageArray.count ;i++){
                        
                        
                        
                        let sourceData =  ((self.sourceMessageArray[i]) as! SLData)
                        
                        if(((sourceData.type == "http" )||(sourceData.type == "https" )))  {
                            
                            sourceMessage.addObject(self.sourceMessageArray[i]);
                         
                           
                        }
                        
                    }
           
                  
                     self.sourceMessageArray.removeAllObjects();
                     self.sourceMessageArray.addObjectsFromArray(sourceMessage as [AnyObject])
                   
                    
                    self.tableView.reloadData();
              
           self.showConnectInf()
   //                          timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, //         selector:#selector(ViewControllerInf.showConnectInf(_:)), userInfo: nil, repeats: true)
//                    self.timer!.fire()
                    
                }
                
            }) { error in
                
            }

            
        }else{
            
            
         
            self.sourceMessageArray.removeAllObjects();
               self.tableView.reloadData();
            
        }
    }
    
    
    func stringFomatTransfom(string:String)-> String{
        
        var string = string as String
        string.insertContentsOf("%22".characters, at: string.startIndex)
        string.insertContentsOf("%22".characters, at: string.endIndex)
        return string
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.sourceMessageArray).count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = ((self.sourceMessageArray[indexPath.row]) as! SLData).name
        cell.textLabel?.font =  UIFont.systemFontOfSize(14)
        return cell
    }
    
//    let urlString = "7.7.7.111:1000"
//    let url = NSURL(string: urlString)
//    UIApplication.sharedApplication().openURL(url!)
//    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let sourceData =  ((self.sourceMessageArray[indexPath.row]) as! SLData)
   
    let address = String((sourceData.address as Array)[0]).stringByAppendingString(":")
    
    let type =   String(sourceData.type).stringByAppendingString("://")
    
    let port =   String(Int(sourceData.port)).stringByAppendingString("")
    
    let firstPath =   String(sourceData.firstPath)
    
    let urlString = type.stringByAppendingString(address).stringByAppendingString(port).stringByAppendingString(firstPath);

    
    let url = NSURL(string: urlString)
      UIApplication.sharedApplication().openURL(url!)
       tableView .deselectRowAtIndexPath(indexPath, animated: true)
    
    }
  
    
    override func tableView(tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 30;
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
       {
        let titleView =   UILabel()
        titleView.frame = CGRectMake(0, 20, SCEENWIGHT, 30)
        titleView.backgroundColor = getColor("BEDDF6")
        titleView.text = "frag2_resource_list".localized
        titleView.textColor =  UIColor .whiteColor()
          return titleView;
      }
    
    
    
    //读取IPC信息
    func getIpcMessage(data:NSData, callback: (String) -> Void)
    {
        do
        {
            try self.session!.sendProviderMessage(data)
            { response in
                if (response != nil)
                {   callback(NSString(data: response!, encoding: NSUTF8StringEncoding) as! String )    }
                else
                {   callback("")   }
            }
        }
        catch
        {callback("")   }
    }
    
    //显示连接信息
    func showConnectInf()
    {
        getIpcMessage(dataIp)
        { (str) -> Void in
             self.ipAddress.text = ""
     
            var str =  String(str)
            if(str == "null"){
                str = ""
            }
            self.ipAddress.text = str
        }
        
        getIpcMessage(dataDNS)
        { (str) -> Void in
           self.DNS1.text = ""
            self.DNS.text = ""
           var str =  String(str)
            if(str == "null"){
                str = ""
            }
            var arr =   str.componentsSeparatedByString(",") as NSArray
            
            if(arr.count == 2){
                self.DNS.text = arr[0] as! String
            }else if (arr.count == 3){
                self.DNS.text = arr[0] as! String
                self.DNS1.text = arr[1] as! String
            }
            
            
           
        }
        
    }
    

    //传递参数
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(timer != nil)
        {
            timer?.invalidate()
            timer=nil
        }
        let controller = segue.destinationViewController as! ViewControllerLog
        controller.manager = sender as? NEVPNManager
    }
    
    //重新连接
    @IBAction func ClickbtnReconnect(sender: AnyObject)
    {

        self.ipAddress.text="frag1_connect_state_1".localized

        self.timeCount=1
        if(self.manager?.connection.status != NEVPNStatus.Disconnected && manager?.connection.status != NEVPNStatus.Invalid)
        {   self.manager?.connection.stopVPNTunnel()    }
    }
    
    //断开连接
    @IBAction func ClickbtnDisconnect(sender: AnyObject)
    {
        if(manager?.connection.status != NEVPNStatus.Disconnected && manager?.connection.status != NEVPNStatus.Invalid)
        {   self.manager?.connection.stopVPNTunnel()    }
        self.performSegueWithIdentifier("back", sender: self.manager)
    }
    
    //取消连接
    @IBAction func ClickbtnCancel(sender: AnyObject)
    {
        self.timeCount = -1
//        self.btnReconnect.hidden=false
//        self.btnDisconnect.hidden=false
//        self.viewLoad.hidden=true
        self.manager?.connection.stopVPNTunnel()
    }
    
//     //时钟进程,用于数据显示和重新连接
    func processTimer1(timer: NSTimer)
    {
        if(timeCount<0)//不工作
        {   return  }
        else if(timeCount==0)//显示实时数据
        {
            do
            {
                try self.session!.sendProviderMessage(dataDebug2)
                { response in
                    if (response != nil)
                    {
                        let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding) as? String
                      
                  
                        print(responseString)
                        
                    }
                }
            }
            catch {}
            return
        }
        else//重新连接
        {
            if(self.manager?.connection.status == NEVPNStatus.Connected)
            {
                if let session = self.manager!.connection as? NETunnelProviderSession,
                    message = "state".dataUsingEncoding(NSASCIIStringEncoding)
                {
                    do
                    {
                        try session.sendProviderMessage(message)
                        { response in
                            if (response != nil)
                            {
                                let responseString = NSString(data: response!, encoding: NSASCIIStringEncoding) as? String
                                if(responseString=="Active")//正常
                                {
                                    self.timeCount=0
//                                    self.btnReconnect.hidden=false
//                                    self.btnDisconnect.hidden=false
//                                    self.viewLoad.hidden=true
                                    self.session = self.manager!.connection as? NETunnelProviderSession
                                }
                                else if(responseString=="Error")//连接错误
                                {
                                    self.timeCount=0
//                                    self.btnReconnect.hidden=false
//                                    self.btnDisconnect.hidden=false
//                                    self.viewLoad.hidden=true
                                    self.manager!.connection.stopVPNTunnel()
                                    let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alertController , animated: true, completion: nil)
                                }
                            }
                        }
//                        self.showConnectInf()
                    }
                    catch {}
                }
            }
            else if(self.manager?.connection.status == NEVPNStatus.Disconnected)
            {
                do
                {   try self.manager!.connection.startVPNTunnel()   }
                catch
                {
                    timer.invalidate()
                    timeCount=0
//                    viewLoad.hidden=true
                    self.manager!.connection.stopVPNTunnel()
                    let alertController = UIAlertController(title: "general_remind".localized, message: "VPNStartup_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController , animated: true, completion: nil)
                }
            }
            else if(self.manager?.connection.status == NEVPNStatus.Invalid)
            {
                timer.invalidate()
                timeCount=0
//                viewLoad.hidden=true
                self.manager!.connection.stopVPNTunnel()
                let alertController = UIAlertController(title: "general_remind".localized, message: "Invalid_configuration".localized, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "general_remind".localized, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController , animated: true, completion: nil)
            }
        }
        //
        timeCount += 1
        //超时
        if(timeCount>timeOut)
        {
            self.timeCount = -1
//            self.txtTime.text="00:00:00"
            self.ipAddress.text="frag1_connect_state_1".localized
//            self.txtCounrRec.text="0"
//            self.txtCountSend.text="0"
//            self.viewLoad.hidden=true
            self.manager?.connection.stopVPNTunnel()
            let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
        }
        
    }


 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
