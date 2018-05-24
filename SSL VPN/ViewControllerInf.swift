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

let SCEENWIGHT = (UIScreen.main.bounds.size.width)


class ViewControllerInf: UITableViewController {
//    @IBOutlet weak var txtTime:UILabel!
      var ipAddress: UILabel!
     var DNS: UILabel!
var DNS1: UILabel!
    var manager:NEVPNManager?
    var session:NETunnelProviderSession?
	var timer:Timer?=nil
    var timeCount:Int = 0
    let timeOut:Int=60
	let dataIp="ip".data(using: String.Encoding.utf8)!
	let dataTime="time".data(using: String.Encoding.utf8)!
	let dataPacket="packet".data(using: String.Encoding.utf8)!
	let dataDNS="DNS".data(using: String.Encoding.utf8)!
	let dataDebug1="debug1".data(using: String.Encoding.utf8)!
	let pingRestart="pingRestart".data(using: String.Encoding.utf8)!
	let dataDebug2="debug2".data(using: String.Encoding.utf8)!
    var Controller = UIViewController()
    var logMessage:String = ""

    var sourceMessageArray: NSMutableArray  = []
    var ControllerLog = ViewControllerLog()

    override func viewDidLoad() {
        super.viewDidLoad()
     
     
        
		let img = UIImage.init(named: "navigationBar736")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 190, 230))
        // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
        
		self.navigationController?.navigationBar.setBackgroundImage(img, for:UIBarMetrics(rawValue: 0)!)
        
        
//              self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navigationBar736"), forBarMetrics:UIBarMetrics(rawValue: 0)!)
        
        self.manager =  ManagerInstance.shareSingle().manager
        
         
        self.headerView()
        if self.manager != nil {
            self.session = self.manager!.connection as? NETunnelProviderSession
            
   
            
            
            
        }
        
        
    }

     func headerView() {
        
        
        let headerView =   UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: SCEENWIGHT, height: 120)
		headerView.backgroundColor = UIColor.white
        
       let titleView =   UILabel()
       titleView.frame = CGRect(x: 0, y: 0, width: SCEENWIGHT, height: 30)
       titleView.backgroundColor = getColor("BEDDF6")
     
    
        
        titleView.text = "frag2_connection_info".localized;
        titleView.textColor = UIColor.white
        
        let ipLabel =   UILabel()
		ipLabel.frame = CGRect(x: 20, y: 40, width: SCEENWIGHT, height: 30)
        ipLabel.backgroundColor = UIColor.white
        
        
        ipLabel.text = "frag2_client_ip".localized
        

        

		ipLabel.font =  UIFont.systemFont(ofSize: 14)
        ipAddress =   UILabel()
		ipAddress.frame = CGRect(x: SCEENWIGHT-120, y: 40, width: 100, height: 30)
        ipAddress.backgroundColor = UIColor.clear
        ipAddress.text = ""
        
        
        ipAddress.textAlignment  = .right
		ipAddress.font =  UIFont.systemFont(ofSize: 14)
        headerView.addSubview(ipLabel)
    
        headerView.addSubview(ipAddress)
          headerView.addSubview(titleView)
        
        let DNSLabel =   UILabel()
		DNSLabel.frame = CGRect(x: 20, y: 70, width: SCEENWIGHT, height: 30)
        DNSLabel.backgroundColor = UIColor.white
        DNSLabel.text = "frag2_dns_content".localized
		DNSLabel.font =  UIFont.systemFont(ofSize: 14)
        
   
        DNS =   UILabel()
		DNS.frame = CGRect(x: SCEENWIGHT-170, y: 70, width: 150, height: 30)
        DNS.backgroundColor = UIColor.clear
        DNS.text = ""
        DNS.textAlignment  = .right
		DNS.font =  UIFont.systemFont(ofSize: 14)
        
        
        
        DNS1 =   UILabel()
		DNS1.frame = CGRect(x: SCEENWIGHT-170, y: 90, width: 150, height: 30)
        DNS1.backgroundColor = UIColor.clear
        DNS1.text = ""
        DNS1.textAlignment  = .right
		DNS1.font =  UIFont.systemFont(ofSize: 14)
        headerView.addSubview(DNSLabel)
        headerView.addSubview(DNS)
           headerView.addSubview(DNS1)
        self.tableView.tableHeaderView = headerView

    }
	override func viewWillDisappear(_ animated: Bool) {
        
  
        super.viewWillDisappear(animated);
        if self.timer != nil {
            
                                self.timer!.invalidate()
                                     self.timer=nil
                            }
        
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
     
//        let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@",,"s1","ios")
//        
 
     
        
        self.ipAddress.text = ""
        self.DNS.text  =  ""
        self.DNS1.text  =  ""
        if ManagerInstance.shareSingle().login == 1 {

            
			let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@", ManagerInstance.shareSingle().IPAddress!,self.stringFomatTransfom(string: ManagerInstance.shareSingle().userName! as String),stringFomatTransfom(string: "ios"))
            
            
            HttpRequest.sourceListpost(loginUrl, params: nil, success: { json in
                
                let model =    json as! SLSourceListModel;
                
                if(model.code  ==  0){
                    var  i = 0;
                    
                    self.sourceMessageArray.setArray(model.data
                    )
                    
                    var sourceMessage: NSMutableArray  = []
					for i in 0..<self.sourceMessageArray.count {
						let sourceData =  ((self.sourceMessageArray[i]) as! SLData)
						if(((sourceData.type == "http" )||(sourceData.type == "https" )))  {
							sourceMessage.add(self.sourceMessageArray[i]);
						}
					}
                     self.sourceMessageArray.removeAllObjects();
					self.sourceMessageArray.addObjects(from: sourceMessage as [AnyObject])
                   
                    
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
		string.insert(contentsOf: "%22".characters, at: string.startIndex)
		string.insert(contentsOf: "%22".characters, at: string.endIndex)
        return string
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.sourceMessageArray).count
    }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		cell.textLabel?.text = ((self.sourceMessageArray[indexPath.row]) as! SLData).name
		cell.textLabel?.font =  UIFont.systemFont(ofSize: 14)
		return cell
	}
    
//    let urlString = "7.7.7.111:1000"
//    let url = NSURL(string: urlString)
//    UIApplication.sharedApplication().openURL(url!)
//    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let sourceData =  ((self.sourceMessageArray[indexPath.row]) as! SLData)
   
	let address = String(describing: (sourceData.address as Array)[0]).appendingFormat(":")
    
		let type =   String(describing: sourceData.type).appendingFormat("://")
    
		let port =   String(describing: Int(sourceData.port)).appendingFormat("")
    
    let firstPath =   String(describing: sourceData.firstPath)
    
    let urlString = type + address + port + firstPath;

    
    let url = NSURL(string: urlString)
		UIApplication.shared.openURL(url! as URL)
		tableView .deselectRow(at: indexPath, animated: true)
    
    }
  
    
	override func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 30;
    }
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
       {
        let titleView =   UILabel()
		titleView.frame = CGRect(x: 0, y: 20, width: SCEENWIGHT, height: 30)
        titleView.backgroundColor = getColor("BEDDF6")
        titleView.text = "frag2_resource_list".localized
        titleView.textColor =  UIColor .white
          return titleView;
      }
    
    
    
    //读取IPC信息
	func getIpcMessage(data:Data, callback: @escaping (String) -> Void)
    {
        do
        {
            try self.session!.sendProviderMessage(data)
            { response in
                if (response != nil)
				{   callback(NSString(data: response!, encoding: String.Encoding.utf8.rawValue)! as String )    }
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
		getIpcMessage(data: dataIp)
        { (str) -> Void in
             self.ipAddress.text = ""
     
            var str =  String(str)
            if(str == "null"){
                str = ""
            }
            self.ipAddress.text = str
        }
        
		getIpcMessage(data: dataDNS)
        { (str) -> Void in
           self.DNS1.text = ""
            self.DNS.text = ""
           var str =  String(str)
            if(str == "null"){
                str = ""
            }
			if let arr = str?.components(separatedBy: ",") {
				if(arr.count == 2){
					self.DNS.text = arr[0]
				}else if (arr.count == 3){
					self.DNS.text = arr[0]
					self.DNS1.text = arr[1]
				}
			}
        }
    }
    

    //传递参数
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) 
	{
        if(timer != nil)
        {
            timer?.invalidate()
            timer=nil
        }
		let controller = segue.destination as! ViewControllerLog
        controller.manager = sender as? NEVPNManager
    }
    
    //重新连接
    @IBAction func ClickbtnReconnect(sender: AnyObject)
    {

        self.ipAddress.text="frag1_connect_state_1".localized

        self.timeCount=1
		if(self.manager?.connection.status != NEVPNStatus.disconnected && manager?.connection.status != NEVPNStatus.invalid)
        {   self.manager?.connection.stopVPNTunnel()    }
    }
    
    //断开连接
    @IBAction func ClickbtnDisconnect(sender: AnyObject)
    {
		if(manager?.connection.status != NEVPNStatus.disconnected && manager?.connection.status != NEVPNStatus.invalid)
        {   self.manager?.connection.stopVPNTunnel()    }
		self.performSegue(withIdentifier: "back", sender: self.manager)
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
	func processTimer1(timer: Timer)
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
						let responseString = NSString(data: response!, encoding: String.Encoding.utf8.rawValue)
                      
                  
                        print(responseString)
                        
                    }
                }
            }
            catch {}
            return
        }
        else//重新连接
        {
			if(self.manager?.connection.status == NEVPNStatus.connected)
            {
                if let session = self.manager!.connection as? NETunnelProviderSession,
					let message = "state".data(using: String.Encoding.ascii)
                {
                    do
                    {
                        try session.sendProviderMessage(message)
                        { response in
                            if (response != nil)
                            {
								let responseString = NSString(data: response!, encoding: String.Encoding.ascii.rawValue)
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
									let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
									alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
									self.present(alertController , animated: true, completion: nil)
                                }
                            }
                        }
//                        self.showConnectInf()
                    }
                    catch {}
                }
            }
			else if(self.manager?.connection.status == NEVPNStatus.disconnected)
            {
                do
                {   try self.manager!.connection.startVPNTunnel()   }
                catch
                {
                    timer.invalidate()
                    timeCount=0
//                    viewLoad.hidden=true
                    self.manager!.connection.stopVPNTunnel()
					let alertController = UIAlertController(title: "general_remind".localized, message: "VPNStartup_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
					alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
					self.present(alertController , animated: true, completion: nil)
                }
            }
			else if(self.manager?.connection.status == NEVPNStatus.invalid)
            {
                timer.invalidate()
                timeCount=0
//                viewLoad.hidden=true
                self.manager!.connection.stopVPNTunnel()
				let alertController = UIAlertController(title: "general_remind".localized, message: "Invalid_configuration".localized, preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "general_remind".localized, style: UIAlertActionStyle.default, handler: nil))
				self.present(alertController , animated: true, completion: nil)
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
			let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
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
