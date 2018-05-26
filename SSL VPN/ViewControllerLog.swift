//
//  ViewController.swift
//  SSL VPN
//
//  Created by shijia on 15/7/28.
//  Copyright © 2015年 shijia. All rights reserved.
//

import UIKit
import Foundation
import NetworkExtension


//swift在时序方面存在严重问题，存在众多非显式的异步操作并导致调用错误
class ViewControllerLog: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var viewLoad: UIView!
//    @IBOutlet weak var viewProcess: UIView!
    @IBOutlet weak var connect: UIButton!
    @IBOutlet weak var txtAdress: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    @IBOutlet weak var connectName: UITextField!

    @IBOutlet weak var botomLineView: UIView!
    var animationV:animationView?
    var session:NETunnelProviderSession?
    var manager:NEVPNManager?
    var timeOut:Double=20


	var timer:Timer?=nil
	var reConnectTimer:Timer?=nil
    var conf:[String:AnyObject]=[:]
    var timeStart=Date()
    var timeCount:Int = 0
    var certification:Bool = false //false 为单向 true为双向
	let pingRestart="pingRestart".data(using: String.Encoding.utf8)!
	let logMessage="debug2".data(using: String.Encoding.utf8)!
    var reConnectTimeCount:Int = 0
    
    var sourceMessageArray: NSMutableArray  = []
    let reConnectTimeOut:Int=60

    var log:String = ""
    
    override func viewDidLoad()
    {
     
        //搜索按钮
        let button1 = UIButton(frame:CGRect(x:0, y:0, width:80, height:18))
		button1.titleLabel!.font    = UIFont.systemFont(ofSize: 18);
		button1.setTitle("证书列表", for: UIControlState(rawValue: UInt(0)))
		button1.addTarget(self,action:#selector(pfxShow),for:UIControlEvents(rawValue: UInt(1)))
        let barButton1 = UIBarButtonItem(customView: button1)
               //设置按钮（注意顺序）
        self.navigationItem.leftBarButtonItems = [barButton1]
		let manger = AFNetworkReachabilityManager.shared()
        
        manger.startMonitoring()
        
		manger.setReachabilityStatusChange { (status) in
            
            switch ( status.rawValue) {
            case -1:
				self.showMessage(message: "未知网络")
                break;
            case 0:
                NSLog("没有网络");
                
				self.showMessage(message: "当前网络异常")
             
                break;
            case 1:
                NSLog("3G|4G");
                break;
            case 2:
                NSLog("WiFi");
                break;
            default:
                break;
            }
            
            
            
        }

        
        
        
//        
//          User.sharedInstanced().reConnect = "reConnect";

        
//        
//        "verification_styleOneSide" = "单向";
//        "verification_styleBothSide" = "双向";
//       
//        let items=["verification_styleOneSide".localized,"verification_styleBothSide".localized] as [AnyObject]
//        let segmented=UISegmentedControl(items:items)
//        segmented.frame = CGRectMake(50, UIScreen.mainScreen().bounds.size.height-150, UIScreen.mainScreen().bounds.size.width-100, 40)
//        segmented.selectedSegmentIndex=0 //默认选中第二项
//        segmented.addTarget(self, action: #selector(segmentDidchange),
//                            forControlEvents: UIControlEvents.ValueChanged)  //添加值改变监听
//        self.view.addSubview(segmented)
        
        
        
        connect.layer.masksToBounds = true
        connect.layer.cornerRadius = 50
        
       connect.showsTouchWhenHighlighted = true
         self.connect.backgroundColor = getColor("A7D54C")
		connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
        ManagerInstance.shared.login = 0
		connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
        
        
		let img = UIImage.init(named: "navigationBar736")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 190, 230))
        // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
        
		self.navigationController?.navigationBar.setBackgroundImage(img, for:UIBarMetrics(rawValue: 0)!)
                self.txtPassword.delegate=self
        //读取配置信息
		if(KeychainWrapper.hasValueForKey(keyName: "Adress"))
		{   self.txtAdress.text = KeychainWrapper.stringForKey(keyName: "Adress")!   }
		if(KeychainWrapper.hasValueForKey(keyName: "UserName"))
		{   self.txtUserName.text = KeychainWrapper.stringForKey(keyName: "UserName")! }
		if(KeychainWrapper.hasValueForKey(keyName: "connectName"))
		{   self.connectName.text = KeychainWrapper.stringForKey(keyName: "connectName")! }
		if(KeychainWrapper.hasValueForKey(keyName: "Password"))
		{   self.txtPassword.text = KeychainWrapper.stringForKey(keyName: "Password")!  }
        //获得VpnManager
        getVpnManager()
        
               
		self.view.isUserInteractionEnabled = true;
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:#selector(fingerTapped)));
        
        
		perform(#selector(autoConnect), with: nil, afterDelay: 2)
      
        
        
    }
//    显示PFX列表
    func pfxShow(){
        let    testVc =  ViewController()

        self.navigationController?.pushViewController(testVc, animated: true)


    }
    
   
    func segmentDidchange(segmented:UISegmentedControl){
        //获得选项的索引
        print(segmented.selectedSegmentIndex)
        //获得选择的文字
        
        if segmented.selectedSegmentIndex == 0 {
            certification = false
        }else{
               certification = true
        }
       
    }
    func autoConnect(){
        
        
        if User.sharedInstanced().autoConnect == "autoConnect" {

			self.ClickbtnConnect(sender: "" as AnyObject)
        
        }
//        print(User.sharedInstanced().autoConnect)
        
    }
//    自动重连
    func autoReConnect(time: Int) -> Void{
        
		let connectTime = TimeInterval(time)

        
		perform(#selector(ReConnect), with: nil, afterDelay: connectTime)
        
    }
    func ReConnect(){
        
//        self.reConnectTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:#selector(processTimer(_:)), userInfo: nil, repeats: true)
//        self.reConnectTimer!.fire()
//        
//        self.timeCount=1
//        if(self.manager?.connection.status != NEVPNStatus.Disconnected && manager?.connection.status != NEVPNStatus.Invalid)
//        {   self.manager?.connection.stopVPNTunnel()
//            }
           }


    @IBAction func historyList(sender: AnyObject) {
           self.addHistory()
    }
        func addHistory()
        {
            
         
                
          let    testVc =  YUTestViewController()
                    testVc.hidesBottomBarWhenPushed = true;

                
                testVc.selectConnectBlock = {  model   in
              
                    
					if let model = model as NSDictionary? as! [String:Any]? {
						let serverIP = model["serverIP"]
						let userName = model["userName"]
						let password = model["password"]
						let connectName = model["connectName"]
						self.txtAdress.text  = serverIP as? String
						self.txtUserName.text = userName as? String
						self.txtPassword.text = password as? String
						self.connectName.text = connectName as? String
					}
                }
            
                self.navigationController?.pushViewController(testVc, animated: true)

            
            
            
        }
	func getIpcMessage(data:Data, callback: @escaping (String) -> Void)
        {
              self.session = self.manager!.connection as? NETunnelProviderSession
    
            do
            {
                try  self.session!.sendProviderMessage(data)
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

    override func didReceiveMemoryWarning()
    {   super.didReceiveMemoryWarning()    }
    
    //传递参数
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) 
	{
        if(timer != nil)
        {
            timer?.invalidate()
            timer=nil
        }
        if(segue.identifier=="next")
        {
//             ManagerInstance().manager = sender as? NEVPNManager
            
          
        }
    }
    
    //点击填充区域进入输入区域
    @IBAction func ClickbtnAdress(sender: AnyObject)
    {
		if(!txtAdress.isFirstResponder)
        {   txtAdress.becomeFirstResponder()    }
    }
    @IBAction func ClickbtnUserName(sender: AnyObject)
    {
		if(!txtUserName.isFirstResponder)
		{   txtUserName.becomeFirstResponder()  }
    }
    @IBAction func ClickPassword(sender: AnyObject)
    {
		if(!txtPassword.isFirstResponder)
        {   txtPassword.becomeFirstResponder()  }
    }
    
    //点击空白区域则关闭键盘
     func fingerTapped()
    {
               self.view.endEditing(true)
        
    }
    
    func stringFomatTransfom(string:String)-> String{
   
        var string = string as String
		string.insert(contentsOf: "%22", at: string.startIndex)
		string.insert(contentsOf: "%22", at: string.endIndex)
               return string
        
    }
    //获取域名后开始登陆
    func startLogin(doMains:NSMutableArray){
        
        self.conf["doMains"] = doMains;

        
        
        
		let loginUrl  = String(format:"https://%@:10442/e/sslvpn/LogInOut/LogInOut.login.json?username=%@&passwd=%@", self.txtAdress.text!,self.stringFomatTransfom(string: self.txtUserName.text!),stringFomatTransfom(string: self.txtPassword.text!))
        
        
        
        HttpRequest.post(loginUrl, params: nil, success: { json in
            
            
            let model =    json as! LoginModel;
            if(model.code  ==  0){
                
             
				self.conf["reConnect"]   =     User.sharedInstanced().reConnect as AnyObject
                if( model.data.verifyClient  == "no")
                    
                {
                    self.conf["ca"] = nil;
                }else{
            //                  双向
                    if (FileWatcher.shared().filePath != nil ){
                        NSLog("-----%@",FileWatcher.shared().filePath)
						let fileManager =   FileManager.default
						let content =   fileManager.contents(atPath: FileWatcher.shared().filePath)! as NSData
                        self.conf["ca"] = content
                        
                    }else{
                        //
						let alertController = UIAlertController(title: "general_remind".localized, message: "Import_the_certificate".localized, preferredStyle: UIAlertControllerStyle.alert)
                        
						alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
						self.present(alertController , animated: true, completion: nil)
                        
                        self.connect.backgroundColor = getColor("A7D54C")
						self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
                        ManagerInstance.shared.login = 0
						self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        
						self.connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
                        animationView.dismiss()
						UserDefaults.standard.removeObject(forKey: "caPassWord")
                        return;
                
                    }
                    
                    
                    
                    
					if (UserDefaults.standard.string(forKey: "caPassWord") == ""  || UserDefaults.standard.string(forKey: "caPassWord") == nil){
						let alertVC = UIAlertController(title: nil, message: "password_for_the_certificate".localized, preferredStyle: UIAlertControllerStyle.alert)
                        
                        // 基本输入框，显示实际输入的内容
						alertVC.addTextField(configurationHandler: { (textFild) in
                            
                        })
						let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default) {
                            
                            (action: UIAlertAction!) -> Void in
                            
                            let login = (alertVC.textFields?.first)! as UITextField
                            if( login.text == "")
                            {
								UserDefaults.standard.set("NOPASSWORD", forKey: "caPassWord")
                            }else{
								UserDefaults.standard.set(login.text, forKey: "caPassWord")
                            }
                            
							self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
                            ManagerInstance.shared.login = 0
							self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                            self.connect.backgroundColor = getColor("A7D54C")
							self.connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
                            
                            
                            
                            
                            //
                        }
                        
                        
						let acCancel = UIAlertAction(title: "general_cancel".localized, style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
                            print("click Cancel")
                            self.connect.backgroundColor = getColor("A7D54C")
							self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
                            ManagerInstance.shared.login = 0
							self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                            
                            
                        }
                        alertVC.addAction(acSure)
                        alertVC.addAction(acCancel)
						self.present(alertVC, animated: true, completion: nil)
                        
                        animationView.dismiss()
                        return
                    }
                    
					let capword = UserDefaults.standard.string(forKey: "caPassWord")! as String
                    
                    
					if !( PrAndPu().extractEveryThing(fromPKCS12File: FileWatcher.shared().filePath, passphrase:capword) ){
						self.showMessage(message: "frag1_validclientCertPassWord".localized);
						UserDefaults.standard.set("", forKey: "caPassWord")
                        return
                    }
                    
					self.conf["caPassWord"] = capword as AnyObject
                    
                    
                }
                
				self.conf["rootCa"] = model.data.certificate as AnyObject
                //                    model.data.otpAuth ==  "yes"
                if(model.data.otpAuth != "yes"){

                    self.startConnect();
                }else{
                    
					let alertVC = UIAlertController(title: nil, message: "Enter_the_OTP_password".localized, preferredStyle: UIAlertControllerStyle.alert)
                    
                    // 基本输入框，显示实际输入的内容
					alertVC.addTextField(configurationHandler: { (textFild) in
                        
                    })
					let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default) {
                        
                        (action: UIAlertAction!) -> Void in
                        
                        let login = (alertVC.textFields?.first)! as UITextField
                        
						let loginOtpUrl  = String(format:"https://%@:10442/e/sslvpn/LogInOut/LogInOut.loginOtp.json?username=%@&otpPassword=%@", self.txtAdress.text!,self.stringFomatTransfom(string: self.txtUserName.text!),self.stringFomatTransfom(string: login.text!))
						self.loginWithOpt(string: loginOtpUrl)
                        //
                    }
                    
                    
					let acCancel = UIAlertAction(title: "general_cancel".localized, style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
                        print("click Cancel")
                        
                        
                        
                        
                        self.connect.backgroundColor = getColor("A7D54C")
						self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
                        ManagerInstance.shared.login = 0
						self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        
                    }
                    alertVC.addAction(acSure)
                    alertVC.addAction(acCancel)
					self.present(alertVC, animated: true, completion: nil)
                    
                    animationView.dismiss()
                    
                    
                }
                
                
                
            }else{
                
				self.showMessage(message: String(model.code))
                
            }
            
            }, failure: { (error) in
				self.showMessage(message: String(error.debugDescription)
        )})
        
        

    
    }
    func getResoureDomains(){
//        判断按钮状态
        if (self.connect.titleLabel?.text == "frag1_connect_state_2".localized) {
            self.connect.backgroundColor = getColor("A7D54C")
			self.ClickbtnCancel(sender: "" as AnyObject)
            animationView.dismiss()
			connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
			connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            ManagerInstance.shared.login = 0
			connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
			animationView.transition(withType: "rippleEffect", withSubtype:kCATransitionFromBottom, for: self.view)
            return
            
        }
        
        if (self.connect.titleLabel?.text == "frag1_connect_state_3".localized)  {
            ManagerInstance.shared.login = 0
            self.connect.backgroundColor = getColor("A7D54C")
			self.ClickbtnCancel(sender: "" as AnyObject)
            animationView.dismiss()
			connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
			connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            ManagerInstance.shared.login = 0
			connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
            
			animationView.transition(withType: "rippleEffect", withSubtype:kCATransitionFromBottom, for: self.view)
            return
        }
        
        
        
        //        插入数据库
        let model =   ZJModel()
        
        model.serverIP = self.txtAdress.text
        model.connectName = self.connectName.text
        model.userName = self.txtUserName.text
        
        ManagerInstance.shared.userName = self.txtUserName.text
        
        ManagerInstance.shared.IPAddress = self.txtAdress.text;
        model.password = self.txtPassword.text
		let arrar = ZJFMDBHandle.manager().selectAllPerson(fromPersonTable: ZJModel.self)
        
		if arrar?.count == 0 {
            ZJFMDBHandle.manager().insertPersonTable(model)
        }
        var  bool = true
		for  person  in arrar! {
            
            
            let per = person as! NSDictionary
			let connectName = per["connectName"] as! String
            if ((connectName.isEqual(model.connectName)) == true)   {
                ZJFMDBHandle.manager().deleteModel(model.connectName)
                ZJFMDBHandle.manager().insertPersonTable(model)
                bool = false
            }
            
        }
        
        if bool {
            
            ZJFMDBHandle.manager().insertPersonTable(model)
            
        }
		if txtAdress.isFirstResponder == true  {
            txtAdress.resignFirstResponder()
        }
		if txtUserName.isFirstResponder == true  {
            txtUserName.resignFirstResponder()
        }
		if txtPassword.isFirstResponder == true  {
            txtPassword.resignFirstResponder()
        }
        //
        if(!testAndSaveInf())
        {    return     }
        
//      获取域名
          let doMains: NSMutableArray  = [];

		let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@", self.txtAdress.text!,self.stringFomatTransfom(string: (self.txtUserName.text! as String)),stringFomatTransfom(string: "ios"))
            HttpRequest.sourceListpost(loginUrl, params: nil, success: { json in
                let model =    json as! SLSourceListModel;
                if(model.code  ==  0){
                    var  i = 0;
                    var  j = 0;
                    var  q = 0;
                   
                    var sourceMessage: NSMutableArray  = []
					for i in 0..<model.data.count {
						let sourceData =  ((model.data[i]) as! SLData)
						if(((sourceData.type == "http" )||(sourceData.type == "https" )))  {
							sourceMessage.add(model.data[i]);
							
						}
					}
         
                  
					for q in 0..<sourceMessage.count{
						let source =  (  sourceMessage[q]  as! SLData)
						for j in 0..<source.address.count {
							let address = source.address[j] as! String
							let isIP = address.isIPAddress() as Bool
							if(isIP == false) {
								
								doMains.add(source.address[j]);
								
							}
						}
					}
					self.startLogin(doMains: doMains);
                    }
             
           
            }) { error in
				self.showMessage(message: error.debugDescription)
 
            }
           
           }

    //开始连接
    @IBAction func ClickbtnConnect(sender: AnyObject)
    {
        
    self.getResoureDomains()
    }
    func loginWithOpt(string:String){
        HttpRequest.post(string, params: nil, success: { (json) in
        
            let model =    json as! LoginModel;
                   if(model.code  ==  0){
              
                self.startConnect();
                }else{
                
					self.showMessage(message: String(model.code))
                
                return;
                
            }
            
            }, failure: { (error) in
				self.showMessage(message: error.debugDescription)
                
        })
        
        
            }
    
    func showMessage(message:String ){
  var mess = message
		if message.components(separatedBy: "155073").count > 1  {
          mess = "E155073".localized
		} else if(message.components(separatedBy: "155074").count > 1){
       mess = "E155074".localized
		}else if(message.components(separatedBy: "159006").count > 1){
        mess = "E159006".localized
		}else if(message.components(separatedBy: "101014").count > 1){
      mess = "E101014".localized
		}else if(message.components(separatedBy: "-1001").count > 1){
                      mess = "service_timeout".localized
            
		}else if(message.components(separatedBy: "-1002").count > 1){
            mess = "not_supportUrl".localized
		}else if(message.components(separatedBy: "-1004").count > 1){
            mess = "Failed_connect_server".localized
		}else if(message.components(separatedBy: "-1005").count > 1){
            mess = "Network_connection_interrupted".localized
		}else if(message.components(separatedBy: "-1009").count > 1){
            mess = "Network_connection_interrupted".localized
        }else{
            mess = "Negotiation_fails".localized
        }
     
        
        
      
		let alertVC = UIAlertController(title: "general_remind".localized, message: mess as String, preferredStyle: UIAlertControllerStyle.alert)
        
        
		let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default) {
            
            (action: UIAlertAction!) -> Void in
			self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
			self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            ManagerInstance.shared.login = 0
             self.connect.backgroundColor = getColor("A7D54C")
			self.connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
           animationView.dismiss()
            
			self.ClickbtnCancel(sender: "" as AnyObject)
            
            //
        }
        
        
   
        alertVC.addAction(acSure)

		self.present(alertVC, animated: true, completion: nil)
    }
      func startConnect(){
        
       
		connect.setTitle("frag1_connect_state_2".localized, for:UIControlState(rawValue: UInt(0)))
		connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
		animationView.show(in: self.view)
    startVPNTunnel
    { (isStart) -> Void in
    if(isStart)
    {
        
        
    self.timeStart=Date()//统计开始连接时间
		self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(ViewControllerLog.processLogin(timer:)), userInfo: nil, repeats: true)
    self.timer!.fire()
    }
    else
    {
    self.timer!.invalidate()
    
    self.manager!.connection.stopVPNTunnel()
        
        
 
        

    
        
           self.showAlterView()
        }}}
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
      
     
        if txtAdress.text == "" {
           txtAdress.becomeFirstResponder()
            return false
        }
        if txtUserName.text == "" {
            txtUserName.becomeFirstResponder()
            return false
        }
        if txtPassword.text == "" {
            txtPassword.becomeFirstResponder()
            return false
        }
		if(connectName.isFirstResponder)
        {connectName.resignFirstResponder();}
		if(txtAdress.isFirstResponder)
        {txtAdress.resignFirstResponder();}
		if(txtUserName.isFirstResponder)
        {txtUserName.resignFirstResponder();}
		if(txtPassword.isFirstResponder)
        {txtPassword.resignFirstResponder();}
        //
//        self.viewLoad.hidden=false
        //
        if(!testAndSaveInf())
        {    return  true   }
        //
        startVPNTunnel
        { (isStart) -> Void in
            if(isStart)
            {
                self.timeStart=Date()//统计开始连接时间
				self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ViewControllerLog.processLogin(timer:)), userInfo: nil, repeats: true)
                self.timer!.fire()
                
            }
            else
            {
                self.timer!.invalidate()
//                self.viewLoad.hidden=true
                self.manager!.connection.stopVPNTunnel()
              
                
                self.showAlterView()
                
            }
        }
        return  true
    }
    func showAlterView() {
		let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
		alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
		self.present(alertController , animated: true, completion: nil)
    }
    //取消连接
    func ClickbtnCancel(sender: AnyObject)
    {
        
        if self.reConnectTimer != nil {
            
            self.reConnectTimer!.invalidate()
            self.reConnectTimer = nil
        }
        
        if(timer != nil)
        {
            timer?.invalidate()
            timer=nil
        }
     
//        self.viewLoad.hidden=true
        self.manager!.connection.stopVPNTunnel()
    }
    
    //检测并保存信息
    func testAndSaveInf()->Bool
    {
        
        
     
        if(self.connectName.text=="")
        {
            let alertController = UIAlertController(title: "general_remind".localized,
													message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
            return false
        }

        
        //检测
        if(self.txtAdress.text=="")
        {
            
            
            
            
            let alertController = UIAlertController(title: "general_remind".localized,
													message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
            return false
        }
        if(self.txtUserName.text=="")
        {
            let alertController = UIAlertController(title: "general_remind".localized,
													message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
            return false
        }
        if(self.txtPassword.text=="")
        {
            let alertController = UIAlertController(title: "general_remind".localized,
													message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
            return false
        }
        //保存
		KeychainWrapper.setString(value: self.txtAdress.text!, forKey: "Adress")
		KeychainWrapper.setString(value: self.txtUserName.text!, forKey: "UserName")
		KeychainWrapper.setString(value: self.txtPassword.text!, forKey: "Password")
		KeychainWrapper.setString(value: self.connectName.text!, forKey: "connectName")
		connect.setTitle("frag1_connect_state_2".localized, for:UIControlState(rawValue: UInt(0)))
		connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
		animationView.show(in: self.view)
      
        return true
    }
    
    //获取VpnManager,为了解决时序问题
    func getVpnManager()
    {
        if(self.manager != nil)
        {return}
		NETunnelProviderManager.loadAllFromPreferences()
        {   newManagers, error in
            guard let vpnManagers = newManagers else { return }
            if(vpnManagers.count==1)
            {
                
              
                self.manager=vpnManagers[0]
				if(self.manager!.connection.status == NEVPNStatus.connected)
                {
                    
                   

                    ManagerInstance.shared.manager = self.manager
                   
                  
//                    self.performSegueWithIdentifier("next", sender: self.manager)
                
                }
				else if(self.manager!.connection.status == NEVPNStatus.connecting)
                {   self.manager!.connection.stopVPNTunnel()
                
                
                }
            }
            else if(vpnManagers.count>1)
            {
                self.manager=vpnManagers[0]
                for i in 1 ..< vpnManagers.count
				{   vpnManagers[i].removeFromPreferences(completionHandler: { error -> Void in} )    }
            }
            else
            {
                let providerProtocol = NETunnelProviderProtocol()
                providerProtocol.providerBundleIdentifier = "com.NISG.SSLVPN.Tunnel"
                providerProtocol.providerConfiguration = self.conf
                providerProtocol.serverAddress = self.txtAdress.text!
                providerProtocol.username=self.txtUserName.text
				providerProtocol.passwordReference=self.txtPassword.text!.data(using: String.Encoding.ascii)
                self.manager = NETunnelProviderManager()
                self.manager!.protocolConfiguration = providerProtocol
				self.manager!.isEnabled=true
				self.manager!.saveToPreferences(
					completionHandler: { (error) -> Void in
                    if(error==nil)
                    {
                        
                   
                        
						NETunnelProviderManager.loadAllFromPreferences()
                        {   newManagers, error in
                            guard let vpnManagers = newManagers else { return }
                            self.manager=vpnManagers[0]
                            
                            
                            
                        }
                    }
                    else
                    {
                        
                        print(error)   }
                })
            }
        }
   
      
    
    }
    
    //启动VPN隧道
	func startVPNTunnel(callback: @escaping (Bool) -> Void)
    {
        
        //写入系统
        
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.NISG.SSLVPN.Tunnel"
        providerProtocol.providerConfiguration = self.conf
        providerProtocol.serverAddress = self.txtAdress.text!
        providerProtocol.username=self.txtUserName.text
		providerProtocol.passwordReference=self.txtPassword.text!.data(using: String.Encoding.ascii)
        self.manager!.protocolConfiguration = providerProtocol
		self.manager!.isEnabled=true
		self.manager!.saveToPreferences
        { (error) -> Void in
            if(error != nil)
            {   callback(false)   }
            else
            {
                do
                {
                    try self.manager!.connection.startVPNTunnel()
                    callback(true)
                }
                catch
                {   callback(false)     }
            }
        }
    }

    //登录进度
	func processLogin(timer: Timer)
    {
        
        
        if User.sharedInstanced().recodeLog == "recodeLog"{
            
			self.getIpcMessage(data: self.logMessage, callback: { (string) in
                //            日志写入文件
                
				self.writeLog(string: string)
                
                
            })
            
            
        }

		if(self.manager?.connection.status == NEVPNStatus.reasserting){
            
            
            
        }
		if(self.manager?.connection.status == NEVPNStatus.disconnecting){
            
            
//            self.showMessage(String("Negotiation_fails".localized))

            
            return
        }

        //状态检测
		if(self.manager?.connection.status == NEVPNStatus.connected)
        {
            if let session = self.manager!.connection as? NETunnelProviderSession,
				let  message = "state".data(using: String.Encoding.ascii)
            {
                do
                {
                    try session.sendProviderMessage(message)
                        { response in
                            if (response != nil)
                            {
								let responseString = NSString(data: response!, encoding: String.Encoding.ascii.rawValue) as String?
                                //print(responseString)
                                if(responseString=="Active")//正常
                                {
                                    
                                    ManagerInstance.shared.login = 1
									print(String(NSDate().timeIntervalSince(self.timeStart))) //打印连接用时
                                    timer.invalidate()
                                 
									self.reConnectTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(self.processTimer(timer:)), userInfo: nil, repeats: true)
                                    self.reConnectTimer!.fire()

									self.connect.setTitle("frag1_connect_state_3".localized, for:UIControlState(rawValue: UInt(0)))
                                    
                                    
                                    
									self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
									self.connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
                               
//                                    if User.sharedInstanced().reConnect == "reConnect" {
//                                        
//                                        
//                                        weak var weakSelf = self
//                                        self.getIpcMessage(self.pingRestart)
//                                        { (str) -> Void in
//                                            
//                                            let time =   Int(60)
//                                            
//                                            
//                                            self.autoReConnect(time)
//                                            
//                                            
//                                        }
//                                        
//                                    }
                                    
                                    
                                    if User.sharedInstanced().recodeLog == "recodeLog"{
      
										self.getIpcMessage(data: self.logMessage, callback: { (string) in
          //            日志写入文件
            
											self.writeLog(string: string)
          
            
        })
               
                                        
                                    }
                                    
                                    animationView.dismiss()
                                    
                                  
									animationView.transition(withType: "rippleEffect", withSubtype:kCATransitionFromBottom, for: self.view)
                                
                                
                                    self.connect.backgroundColor = getColor("FB6947")
                                    ManagerInstance.shared.manager = self.manager
                                    
                                    
                                }
                                else if(responseString=="Error")//连接错误
                                {
                                    timer.invalidate()

                                    self.manager!.connection.stopVPNTunnel()
									let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
									alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
									self.present(alertController , animated: true, completion: nil)
                                }
                            }
                    }
                }
                catch {}
            }
        }
		else if(self.manager?.connection.status == NEVPNStatus.disconnected)
        {
            
//            /*! @const NEVPNStatusInvalid The VPN is not configured. */
//            case Invalid
//            /*! @const NEVPNStatusDisconnected The VPN is disconnected. */
//            case Disconnected
//            /*! @const NEVPNStatusConnecting The VPN is connecting. */
//            case Connecting
//            /*! @const NEVPNStatusConnected The VPN is connected. */
//            case Connected
//            /*! @const NEVPNStatusReasserting The VPN is reconnecting following loss of underlying network connectivity. */
//            case Reasserting
//            /*! @const NEVPNStatusDisconnecting The VPN is disconnecting. */
//            case Disconnecting
         

       
            
            
            do
            {   try self.manager!.connection.startVPNTunnel()   }
            catch
            {
                
                timer.invalidate()
//                viewLoad.hidden=true
                self.manager!.connection.stopVPNTunnel()
				let alertController = UIAlertController(title: "general_remind".localized , message: "VPNStartup_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
				self.present(alertController , animated: true, completion: nil)
            }
        }
		else if(self.manager?.connection.status == NEVPNStatus.invalid)
        {
            timer.invalidate()
//            viewLoad.hidden=true
            self.manager!.connection.stopVPNTunnel()
			let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController , animated: true, completion: nil)
        }
        //超时
		if(NSDate().timeIntervalSince(timeStart)>timeOut)
        {

    
			UserDefaults.standard.removeObject(forKey: "caPassWord")

            
            animationView.dismiss()
			connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
             self.connect.backgroundColor = getColor("A7D54C")
            ManagerInstance.shared.login = 0
			connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
			connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
            
            timer.invalidate()
//            viewLoad.hidden=true
            self.manager!.connection.stopVPNTunnel()
//            if User.sharedInstanced().reConnect == "reConnect" {
//                
//                
//                if self.reConnectTimer != nil {
//                    
//                    self.reConnectTimer!.invalidate()
//                         self.reConnectTimer=nil
//                }
//                
//                if(self.timer != nil)
//                {
//                    self.timer?.invalidate()
//                    self.timer=nil
//                }
//                    
//                
//                self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
//                ManagerInstance.shareSingle().login = 0
//                self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
//                self.connect.backgroundColor = getColor("A7D54C")
//                self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
//                animationView.dismiss()
//                
//                
//                
//                self.startConnect();
//                
//                
//                return
//            }
            
            
			animationView.transition(withType: "rippleEffect", withSubtype:kCATransitionFromBottom, for: self.view)

            if(self.conf["ca"] == nil){
				let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout".localized, preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
				self.present(alertController , animated: true, completion: nil)
            }else{
				let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout2".localized, preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
				self.present(alertController , animated: true, completion: nil)
            }
            
            
            
           
        }
    }

    
//    写入日志
    
    
    func writeLog(string: String) -> Void{
        if  User.sharedInstanced().readFile() == nil {
            
			User.sharedInstanced().write(toFile: string as String)
        } else {
            
            if User.sharedInstanced().cancelContent() {
				User.sharedInstanced().write(toFile: string as String)
               
                
            }
            
        }
        }
    
    //时钟进程,用于数据显示和重新连接
	func processTimer(timer: Timer)
                //重新连接
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
								let responseString = NSString(data: response!, encoding: String.Encoding.ascii.rawValue) as String?
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
									let alertController = UIAlertController(title: "general_remind".localized, message: "vpn_timeout".localized, preferredStyle: UIAlertControllerStyle.alert)
									alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.default, handler: nil))
									self.present(alertController , animated: true, completion: nil)
                                }
                            }
                        }
                
                    }
                    catch {}
                }
            }
            
			if(self.manager?.connection.status == NEVPNStatus.disconnected)
            {
                
                
                
                self.connect.backgroundColor = getColor("A7D54C")
				self.connect.setTitle("frag1_connect_state_1".localized, for:UIControlState(rawValue: UInt(0)))
                ManagerInstance.shared.login = 0
				self.connect.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                
				self.connect.setBackgroundImage(UIImage.init(named:""), for: UIControlState(rawValue: UInt(0)))
                animationView.dismiss()
            
                if self.reConnectTimer != nil {
                    
                                        self.reConnectTimer!.invalidate()
                                             self.reConnectTimer=nil
                                    }
                    
            
            }

    }
    
    
    
    
    
    
}

