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


    var timer:NSTimer?=nil
    var reConnectTimer:NSTimer?=nil
    var conf:[String:AnyObject]=[:]
    var timeStart=NSDate()
    var timeCount:Int = 0
    var certification:Bool = false //false 为单向 true为双向
    let pingRestart="pingRestart".dataUsingEncoding(NSUTF8StringEncoding)!
    let logMessage="debug2".dataUsingEncoding(NSUTF8StringEncoding)!
    var reConnectTimeCount:Int = 0
    
    var sourceMessageArray: NSMutableArray  = []
    let reConnectTimeOut:Int=60

    var log:String = ""
    
    override func viewDidLoad()
    {
     
        //搜索按钮
        let button1 = UIButton(frame:CGRect(x:0, y:0, width:80, height:18))
        button1.titleLabel!.font    = UIFont.systemFontOfSize(18);
        button1.setTitle("证书列表", forState: UIControlState(rawValue: UInt(0)))
        button1.addTarget(self,action:#selector(pfxShow),forControlEvents:UIControlEvents(rawValue: UInt(1)))
        let barButton1 = UIBarButtonItem(customView: button1)
               //设置按钮（注意顺序）
        self.navigationItem.leftBarButtonItems = [barButton1]
                let manger = AFNetworkReachabilityManager.sharedManager()
        
        manger.startMonitoring()
        
        manger.setReachabilityStatusChangeBlock { (status) in
            
            switch ( status.rawValue) {
            case -1:
                self.showMessage("未知网络")
                break;
            case 0:
                NSLog("没有网络");
                
               self.showMessage("当前网络异常")
             
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
       connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
        ManagerInstance.shareSingle().login = 0
          connect.titleLabel?.font = UIFont.systemFontOfSize(14)
           connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
        
        
                let img = UIImage.init(named: "navigationBar736")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 190, 230))
        // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
        
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics:UIBarMetrics(rawValue: 0)!)
                self.txtPassword.delegate=self
        //读取配置信息
        if(KeychainWrapper.hasValueForKey("Adress"))
        {   self.txtAdress.text = KeychainWrapper.stringForKey("Adress")!   }
        if(KeychainWrapper.hasValueForKey("UserName"))
        {   self.txtUserName.text = KeychainWrapper.stringForKey("UserName")! }
        if(KeychainWrapper.hasValueForKey("connectName"))
        {   self.connectName.text = KeychainWrapper.stringForKey("connectName")! }
        if(KeychainWrapper.hasValueForKey("Password"))
        {   self.txtPassword.text = KeychainWrapper.stringForKey("Password")!  }
        //获得VpnManager
        getVpnManager()
        
               
        self.view.userInteractionEnabled = true;
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:#selector(fingerTapped)));
        
        
        performSelector(#selector(autoConnect), withObject: nil, afterDelay: 2)
      
        
        
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

                self.ClickbtnConnect("")
        
        }
//        print(User.sharedInstanced().autoConnect)
        
    }
//    自动重连
    func autoReConnect(time: Int) -> Void{
        
      let connectTime = NSTimeInterval(time)

        
      performSelector(#selector(ReConnect), withObject: nil, afterDelay: connectTime)
        
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
              
                    
                   let model =  model  as Dictionary
                   let serverIP = model["serverIP"]
                    let userName = model["userName"]
                    let password = model["password"]
                    let connectName = model["connectName"]
                    self.txtAdress.text  = serverIP as? String
                    self.txtUserName.text = userName as? String
                    self.txtPassword.text = password as? String
                   self.connectName.text = connectName as? String

                    
                    
                }
            
                self.navigationController?.pushViewController(testVc, animated: true)

            
            
            
        }
    func getIpcMessage(data:NSData, callback: (String) -> Void)
        {
              self.session = self.manager!.connection as? NETunnelProviderSession
    
            do
            {
                try  self.session!.sendProviderMessage(data)
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

    override func didReceiveMemoryWarning()
    {   super.didReceiveMemoryWarning()    }
    
    //传递参数
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
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
        if(!txtAdress.isFirstResponder())
        {   txtAdress.becomeFirstResponder()    }
    }
    @IBAction func ClickbtnUserName(sender: AnyObject)
    {
        if(!txtUserName.isFirstResponder())
        {   txtUserName.becomeFirstResponder()  }
    }
    @IBAction func ClickPassword(sender: AnyObject)
    {
        if(!txtPassword.isFirstResponder())
        {   txtPassword.becomeFirstResponder()  }
    }
    
    //点击空白区域则关闭键盘
     func fingerTapped()
    {
               self.view.endEditing(true)
        
    }
    
    func stringFomatTransfom(string:String)-> String{
   
        var string = string as String
        string.insertContentsOf("%22".characters, at: string.startIndex)
        string.insertContentsOf("%22".characters, at: string.endIndex)
               return string
        
    }
    //获取域名后开始登陆
    func startLogin(doMains:NSMutableArray){
        
        self.conf["doMains"] = doMains;

        
        
        
        let loginUrl  = String(format:"https://%@:10442/e/sslvpn/LogInOut/LogInOut.login.json?username=%@&passwd=%@", self.txtAdress.text!,self.stringFomatTransfom(self.txtUserName.text!),stringFomatTransfom(self.txtPassword.text!))
        
        
        
        HttpRequest.post(loginUrl, params: nil, success: { json in
            
            
            let model =    json as! LoginModel;
            if(model.code  ==  0){
                
             
                self.conf["reConnect"]   =     User.sharedInstanced().reConnect
                if( model.data.verifyClient  == "no")
                    
                {
                    self.conf["ca"] = nil;
                }else{
            //                  双向
                    if (FileWatcher.shared().filePath != nil ){
                        NSLog("-----%@",FileWatcher.shared().filePath)
                        let fileManager =   NSFileManager.defaultManager()
                        let content =   fileManager.contentsAtPath(FileWatcher.shared().filePath)! as NSData
                        self.conf["ca"] = content
                        
                    }else{
                        //
                        let alertController = UIAlertController(title: "general_remind".localized, message: "Import_the_certificate".localized, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alertController , animated: true, completion: nil)
                        
                        self.connect.backgroundColor = getColor("A7D54C")
                        self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
                        ManagerInstance.shareSingle().login = 0
                        self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                        
                        self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
                        animationView.dismiss()
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("caPassWord")
                        return;
                
                    }
                    
                    
                    
                    
                    if (NSUserDefaults.standardUserDefaults().stringForKey("caPassWord") == ""  || NSUserDefaults.standardUserDefaults().stringForKey("caPassWord") == nil){
                        let alertVC = UIAlertController(title: nil, message: "password_for_the_certificate".localized, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // 基本输入框，显示实际输入的内容
                        alertVC.addTextFieldWithConfigurationHandler({ (textFild) in
                            
                        })
                        let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default) {
                            
                            (action: UIAlertAction!) -> Void in
                            
                            let login = (alertVC.textFields?.first)! as UITextField
                            if( login.text == "")
                            {
                                NSUserDefaults.standardUserDefaults().setObject("NOPASSWORD", forKey: "caPassWord")
                            }else{
                                NSUserDefaults.standardUserDefaults().setObject(login.text, forKey: "caPassWord")
                            }
                            
                            self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
                            ManagerInstance.shareSingle().login = 0
                            self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                            self.connect.backgroundColor = getColor("A7D54C")
                            self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
                            
                            
                            
                            
                            //
                        }
                        
                        
                        let acCancel = UIAlertAction(title: "general_cancel".localized, style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
                            print("click Cancel")
                            self.connect.backgroundColor = getColor("A7D54C")
                            self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
                            ManagerInstance.shareSingle().login = 0
                            self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                            
                            
                        }
                        alertVC.addAction(acSure)
                        alertVC.addAction(acCancel)
                        self.presentViewController(alertVC, animated: true, completion: nil)
                        
                        animationView.dismiss()
                        return
                    }
                    
                    let capword = NSUserDefaults.standardUserDefaults().stringForKey("caPassWord")! as String
                    
                    
                    if !( PrAndPu().extractEveryThingFromPKCS12File(FileWatcher.shared().filePath, passphrase:capword) ){
                        self.showMessage("frag1_validclientCertPassWord".localized);
                        NSUserDefaults.standardUserDefaults().setObject("", forKey: "caPassWord")
                        return
                    }
                    
                    self.conf["caPassWord"] = capword
                    
                    
                }
                
                self.conf["rootCa"] = model.data.certificate
                //                    model.data.otpAuth ==  "yes"
                if(model.data.otpAuth != "yes"){

                    self.startConnect();
                }else{
                    
                let alertVC = UIAlertController(title: nil, message: "Enter_the_OTP_password".localized, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    // 基本输入框，显示实际输入的内容
                    alertVC.addTextFieldWithConfigurationHandler({ (textFild) in
                        
                    })
                    let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default) {
                        
                        (action: UIAlertAction!) -> Void in
                        
                        let login = (alertVC.textFields?.first)! as UITextField
                        
                        let loginOtpUrl  = String(format:"https://%@:10442/e/sslvpn/LogInOut/LogInOut.loginOtp.json?username=%@&otpPassword=%@", self.txtAdress.text!,self.stringFomatTransfom(self.txtUserName.text!),self.stringFomatTransfom(login.text!))
                        self.loginWithOpt(loginOtpUrl)
                        //
                    }
                    
                    
                    let acCancel = UIAlertAction(title: "general_cancel".localized, style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
                        print("click Cancel")
                        
                        
                        
                        
                        self.connect.backgroundColor = getColor("A7D54C")
                        self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
                        ManagerInstance.shareSingle().login = 0
                        self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                        
                    }
                    alertVC.addAction(acSure)
                    alertVC.addAction(acCancel)
                    self.presentViewController(alertVC, animated: true, completion: nil)
                    
                    animationView.dismiss()
                    
                    
                }
                
                
                
            }else{
                
                self.showMessage(String(model.code))
                
            }
            
            }, failure: { (error) in
                self.showMessage(String(error.description))
        })
        
        

    
    }
    func getResoureDomains(){
//        判断按钮状态
        if (self.connect.titleLabel?.text == "frag1_connect_state_2".localized) {
            self.connect.backgroundColor = getColor("A7D54C")
            self.ClickbtnCancel("")
            animationView.dismiss()
            connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
            connect.titleLabel?.font = UIFont.systemFontOfSize(14)
            ManagerInstance.shareSingle().login = 0
            connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
            animationView.transitionWithType("rippleEffect", withSubtype:kCATransitionFromBottom, forView: self.view)
            return
            
        }
        
        if (self.connect.titleLabel?.text == "frag1_connect_state_3".localized)  {
            ManagerInstance.shareSingle().login = 0
            self.connect.backgroundColor = getColor("A7D54C")
            self.ClickbtnCancel("")
            animationView.dismiss()
            connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
            connect.titleLabel?.font = UIFont.systemFontOfSize(14)
            ManagerInstance.shareSingle().login = 0
            connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
            
            animationView.transitionWithType("rippleEffect", withSubtype:kCATransitionFromBottom, forView: self.view)
            return
        }
        
        
        
        //        插入数据库
        let model =   ZJModel()
        
        model.serverIP = self.txtAdress.text
        model.connectName = self.connectName.text
        model.userName = self.txtUserName.text
        
        ManagerInstance.shareSingle().userName = self.txtUserName.text
        
        ManagerInstance.shareSingle().IPAddress = self.txtAdress.text;
        model.password = self.txtPassword.text
        let arrar = ZJFMDBHandle.manager().selectAllPersonFromPersonTable(ZJModel)
        
        if arrar.count == 0 {
            ZJFMDBHandle.manager().insertPersonTable(model)
        }
        var  bool = true
        for  person  in arrar {
            
            
            let per = person as! NSDictionary
            if ((per["connectName"]?.isEqual(model.connectName)) == true)   {
                ZJFMDBHandle.manager().deleteModel(model.connectName)
                ZJFMDBHandle.manager().insertPersonTable(model)
                bool = false
            }
            
        }
        
        if bool {
            
            ZJFMDBHandle.manager().insertPersonTable(model)
            
        }
            if txtAdress.isFirstResponder() == true  {
            txtAdress.resignFirstResponder()
        }
            if txtUserName.isFirstResponder() == true  {
            txtUserName.resignFirstResponder()
        }
        if txtPassword.isFirstResponder() == true  {
            txtPassword.resignFirstResponder()
        }
        //
        if(!testAndSaveInf())
        {    return     }
        
//      获取域名
          let doMains: NSMutableArray  = [];

          let loginUrl  = String(format:"https://%@:10442/e/sslvpn/resource/Resource.getUserResourceList.json?userName=%@&loginType=%@", self.txtAdress.text!,self.stringFomatTransfom((self.txtUserName.text! as String)),stringFomatTransfom("ios"))
            HttpRequest.sourceListpost(loginUrl, params: nil, success: { json in
                let model =    json as! SLSourceListModel;
                if(model.code  ==  0){
                    var  i = 0;
                    var  j = 0;
                    var  q = 0;
                   
                    var sourceMessage: NSMutableArray  = []
                    for( i = 0 ;i < model.data.count ;i++){
                        let sourceData =  ((model.data[i]) as! SLData)
                        if(((sourceData.type == "http" )||(sourceData.type == "https" )))  {
                            sourceMessage.addObject(model.data[i]);
                  
                        }
                    }
         
                  

                    for( q = 0 ;q < sourceMessage.count ;q++)
                    {
                        let source =  (  sourceMessage[q]  as! SLData)
                        for( j = 0 ;j < source.address.count ;j++){
                            let isIP = (source.address[j]).isIPAddress() as Bool
                            if(isIP == false) {
              
                                doMains.addObject(source.address[j]);
                                
                    }
                    }
                    }
                    self.startLogin(doMains);
                    }
             
           
            }) { error in
                self.showMessage(error.description)
 
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
                
                self.showMessage(String(model.code))
                
                return;
                
            }
            
            }, failure: { (error) in
                 self.showMessage(error.description)
                
        })
        
        
            }
    
    func showMessage(message:NSString ){
  var mess = message
        if message.componentsSeparatedByString("155073").count > 1  {
          mess = "E155073".localized
        } else if(message.componentsSeparatedByString("155074").count > 1){
       mess = "E155074".localized
        }else if(message.componentsSeparatedByString("159006").count > 1){
        mess = "E159006".localized
        }else if(message.componentsSeparatedByString("101014").count > 1){
      mess = "E101014".localized
        }else if(message.componentsSeparatedByString("-1001").count > 1){
                      mess = "service_timeout".localized
            
        }else if(message.componentsSeparatedByString("-1002").count > 1){
            mess = "not_supportUrl".localized
        }else if(message.componentsSeparatedByString("-1004").count > 1){
            mess = "Failed_connect_server".localized
        }else if(message.componentsSeparatedByString("-1005").count > 1){
            mess = "Network_connection_interrupted".localized
        }else if(message.componentsSeparatedByString("-1009").count > 1){
            mess = "Network_connection_interrupted".localized
        }else{
            mess = "Negotiation_fails".localized
        }
     
        
        
      
        let alertVC = UIAlertController(title: "general_remind".localized, message: mess as String, preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let acSure = UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default) {
            
            (action: UIAlertAction!) -> Void in
            self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
            self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
            ManagerInstance.shareSingle().login = 0
             self.connect.backgroundColor = getColor("A7D54C")
             self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
           animationView.dismiss()
            
            self.ClickbtnCancel("")
            
            //
        }
        
        
   
        alertVC.addAction(acSure)

        self.presentViewController(alertVC, animated: true, completion: nil)
    }
      func startConnect(){
        
       
        connect.setTitle("frag1_connect_state_2".localized, forState:UIControlState(rawValue: UInt(0)))
        connect.titleLabel?.font = UIFont.systemFontOfSize(14)
        connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
        animationView.showInView(self.view)
    startVPNTunnel
    { (isStart) -> Void in
    if(isStart)
    {
        
        
    self.timeStart=NSDate()//统计开始连接时间
    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:#selector(ViewControllerLog.processLogin(_:)), userInfo: nil, repeats: true)
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
        if(connectName.isFirstResponder())
        {connectName.resignFirstResponder();}
        if(txtAdress.isFirstResponder())
        {txtAdress.resignFirstResponder();}
        if(txtUserName.isFirstResponder())
        {txtUserName.resignFirstResponder();}
        if(txtPassword.isFirstResponder())
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
                self.timeStart=NSDate()//统计开始连接时间
              self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:#selector(ViewControllerLog.processLogin(_:)), userInfo: nil, repeats: true)
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
        let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController , animated: true, completion: nil)
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
                message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
            return false
        }

        
        //检测
        if(self.txtAdress.text=="")
        {
            
            
            
            
            let alertController = UIAlertController(title: "general_remind".localized,
                                                    message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
            return false
        }
        if(self.txtUserName.text=="")
        {
            let alertController = UIAlertController(title: "general_remind".localized,
                                                    message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
            return false
        }
        if(self.txtPassword.text=="")
        {
            let alertController = UIAlertController(title: "general_remind".localized,
                                                    message: "frag1_filltxt".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
            return false
        }
        //保存
        KeychainWrapper.setString(self.txtAdress.text!, forKey: "Adress")
        KeychainWrapper.setString(self.txtUserName.text!, forKey: "UserName")
        KeychainWrapper.setString(self.txtPassword.text!, forKey: "Password")
        KeychainWrapper.setString(self.connectName.text!, forKey: "connectName")
         connect.setTitle("frag1_connect_state_2".localized, forState:UIControlState(rawValue: UInt(0)))
        connect.titleLabel?.font = UIFont.systemFontOfSize(14)
           connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
         animationView.showInView(self.view)
      
        return true
    }
    
    //获取VpnManager,为了解决时序问题
    func getVpnManager()
    {
        if(self.manager != nil)
        {return}
        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler()
        {   newManagers, error in
            guard let vpnManagers = newManagers else { return }
            if(vpnManagers.count==1)
            {
                
              
                self.manager=vpnManagers[0]
                if(self.manager!.connection.status == NEVPNStatus.Connected)
                {
                    
                   

                    ManagerInstance.shareSingle().manager = self.manager
                   
                  
//                    self.performSegueWithIdentifier("next", sender: self.manager)
                
                }
                else if(self.manager!.connection.status == NEVPNStatus.Connecting)
                {   self.manager!.connection.stopVPNTunnel()
                
                
                }
            }
            else if(vpnManagers.count>1)
            {
                self.manager=vpnManagers[0]
                for i in 1 ..< vpnManagers.count
                {   vpnManagers[i].removeFromPreferencesWithCompletionHandler({ error -> Void in} )    }
            }
            else
            {
                let providerProtocol = NETunnelProviderProtocol()
                providerProtocol.providerBundleIdentifier = "com.NISG.SSLVPN.Tunnel"
                providerProtocol.providerConfiguration = self.conf
                providerProtocol.serverAddress = self.txtAdress.text!
                providerProtocol.username=self.txtUserName.text
                providerProtocol.passwordReference=self.txtPassword.text!.dataUsingEncoding(NSASCIIStringEncoding)
                self.manager = NETunnelProviderManager()
                self.manager!.protocolConfiguration = providerProtocol
                self.manager!.enabled=true
                self.manager!.saveToPreferencesWithCompletionHandler(
                { (error) -> Void in
                    if(error==nil)
                    {
                        
                   
                        
                        NETunnelProviderManager.loadAllFromPreferencesWithCompletionHandler()
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
    func startVPNTunnel(callback: (Bool) -> Void)
    {
        
        //写入系统
        
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.NISG.SSLVPN.Tunnel"
        providerProtocol.providerConfiguration = self.conf
        providerProtocol.serverAddress = self.txtAdress.text!
        providerProtocol.username=self.txtUserName.text
        providerProtocol.passwordReference=self.txtPassword.text!.dataUsingEncoding(NSASCIIStringEncoding)
        self.manager!.protocolConfiguration = providerProtocol
        self.manager!.enabled=true
        self.manager!.saveToPreferencesWithCompletionHandler
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
    func processLogin(timer: NSTimer)
    {
        
        
        if User.sharedInstanced().recodeLog == "recodeLog"{
            
            self.getIpcMessage(self.logMessage, callback: { (string) in
                //            日志写入文件
                
                self.writeLog(string)
                
                
            })
            
            
        }

        if(self.manager?.connection.status == NEVPNStatus.Reasserting){
            
            
            
        }
        if(self.manager?.connection.status == NEVPNStatus.Disconnecting){
            
            
//            self.showMessage(String("Negotiation_fails".localized))

            
            return
        }

        //状态检测
        if(self.manager?.connection.status == NEVPNStatus.Connected)
        {
            if let session = self.manager!.connection as? NETunnelProviderSession,
              let  message = "state".dataUsingEncoding(NSASCIIStringEncoding)
            {
                do
                {
                    try session.sendProviderMessage(message)
                        { response in
                            if (response != nil)
                            {
                                let responseString = NSString(data: response!, encoding: NSASCIIStringEncoding) as? String
                                //print(responseString)
                                if(responseString=="Active")//正常
                                {
                                    
                                    ManagerInstance.shareSingle().login = 1
                                    print(String(NSDate().timeIntervalSinceDate(self.timeStart))) //打印连接用时
                                    timer.invalidate()
                                 
                                    self.reConnectTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:#selector(self.processTimer(_:)), userInfo: nil, repeats: true)
                                    self.reConnectTimer!.fire()

                                 self.connect.setTitle("frag1_connect_state_3".localized, forState:UIControlState(rawValue: UInt(0)))
                                    
                                    
                                    
                                    self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                                    self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
                               
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
      
        self.getIpcMessage(self.logMessage, callback: { (string) in
          //            日志写入文件
            
            self.writeLog(string)
          
            
        })
               
                                        
                                    }
                                    
                                    animationView.dismiss()
                                    
                                  
                                    animationView.transitionWithType("rippleEffect", withSubtype:kCATransitionFromBottom, forView: self.view)
                                
                                
                                    self.connect.backgroundColor = getColor("FB6947")
                                    ManagerInstance.shareSingle().manager = self.manager
                                    
                                    
                                }
                                else if(responseString=="Error")//连接错误
                                {
                                    timer.invalidate()

                                    self.manager!.connection.stopVPNTunnel()
                                    let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alertController , animated: true, completion: nil)
                                }
                            }
                    }
                }
                catch {}
            }
        }
        else if(self.manager?.connection.status == NEVPNStatus.Disconnected)
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
                let alertController = UIAlertController(title: "general_remind".localized , message: "VPNStartup_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController , animated: true, completion: nil)
            }
        }
        else if(self.manager?.connection.status == NEVPNStatus.Invalid)
        {
            timer.invalidate()
//            viewLoad.hidden=true
            self.manager!.connection.stopVPNTunnel()
            let alertController = UIAlertController(title: "general_remind".localized, message: "authentication_failed".localized, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController , animated: true, completion: nil)
        }
        //超时
        if(NSDate().timeIntervalSinceDate(timeStart)>timeOut)
        {

    
            NSUserDefaults.standardUserDefaults().removeObjectForKey("caPassWord")

            
            animationView.dismiss()
            connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
             self.connect.backgroundColor = getColor("A7D54C")
            ManagerInstance.shareSingle().login = 0
            connect.titleLabel?.font = UIFont.systemFontOfSize(14)
connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
            
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
            
            
            animationView.transitionWithType("rippleEffect", withSubtype:kCATransitionFromBottom, forView: self.view)

            if(self.conf["ca"] == nil){
                let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout".localized, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController , animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "general_remind".localized, message: "service_timeout2".localized, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController , animated: true, completion: nil)
            }
            
            
            
           
        }
    }

    
//    写入日志
    
    
    func writeLog(string: NSString) -> Void{
        if  User.sharedInstanced().readFile() == nil {
            
            User.sharedInstanced().writeToFile(string as String)
        } else {
            
            if User.sharedInstanced().cancelContent() {
                User.sharedInstanced().writeToFile(string as String)
               
                
            }
            
        }
        }
    
    //时钟进程,用于数据显示和重新连接
    func processTimer(timer: NSTimer)
                //重新连接
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
                                    let alertController = UIAlertController(title: "general_remind".localized, message: "vpn_timeout".localized, preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "general_ok".localized, style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alertController , animated: true, completion: nil)
                                }
                            }
                        }
                
                    }
                    catch {}
                }
            }
            
            if(self.manager?.connection.status == NEVPNStatus.Disconnected)
            {
                
                
                
                self.connect.backgroundColor = getColor("A7D54C")
                self.connect.setTitle("frag1_connect_state_1".localized, forState:UIControlState(rawValue: UInt(0)))
                ManagerInstance.shareSingle().login = 0
                self.connect.titleLabel?.font = UIFont.systemFontOfSize(14)
                
                self.connect.setBackgroundImage(UIImage.init(named:""), forState: UIControlState(rawValue: UInt(0)))
                animationView.dismiss()
            
                if self.reConnectTimer != nil {
                    
                                        self.reConnectTimer!.invalidate()
                                             self.reConnectTimer=nil
                                    }
                    
            
            }

    }
    
    
    
    
    
    
}

