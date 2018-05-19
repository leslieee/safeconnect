//
//  RequestHandler.swift
//  SSL Tunnel
//
//  Created by shijia on 15/8/5.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation
import NetworkExtension

//swift的定时器存在问题，所以将众多方法写在一个定时器下
class PacketTunnelProvider: NEPacketTunnelProvider
{
    var isConnected=false
    var session: NWUDPSession? = nil
    var pendingStartCompletion: (NSError? -> Void)?
    var pendingStopCompletion: (Void -> Void)?
    var pendingInformationCompletion: (NSData? -> Void)?
    var countSend:Int=0
    var countRec:Int=0
    var timeRec=NSDate()
    var conf:[String:AnyObject]=[:]
    //
    let sslVPN = SSLVPN()
    //
    var threadConnect:NSThread? = nil
    var timePing:UInt32=5
    var timePingRestart:UInt32=20
    let timeTLS:UInt32=20//tls握手限长
    let countRetry:UInt32=100//重新发送连接请求的次数
    var ipAdress:String?=nil
     var errorMessage:NSMutableString?=""
       var DNSString:NSMutableString?=""
//     var messageArray = [AnyObject]()

    //状态维护线程
    func testConnect(sender:AnyObject)
    {
        var nTLS:UInt32=0
        var nRetry:UInt32=0
        var nPingRestart:UInt32=0
        while(true)
        {
            if(!isConnected) //握手阶段
            {
                //超次，关闭插件
                if(nRetry>=countRetry)
                {
                   
                    let string  = "The request for transmission has been exceeded a predetermined number of times"
//                    self.messageArray.append(string)
                    
                    
                    self.sslVPN.state = SSLVPNState.Error
                    
                    
                    threadConnect?.cancel()
                    exit(0)
                }
                //未超次，重连机制
                if(sslVPN.state == SSLVPNState.Initial)
                {
                    
                    let messageHeader  = "SSLVPN State : "
                    
                
                    self.addMessageToArray(messageHeader, message: String(sslVPN.state))
                    
                    //没收到服务器应答,再次发送请求数据包
//                    self.session?.writeMultipleDatagrams(self.sslVPN.readControlChannel(), completionHandler: { (error: NSError?) -> Void in})
                     self.session?.writeMultipleDatagrams(self.sslVPN.readControlChannel(), completionHandler: { (error) in
                        
                   
                        self.addMessageToArray("Handshake Phase : the times of request : ", message: String(nRetry))
                        
                        if error != nil {
                            self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                        }

                        
                     })
                    
                    
                    
                    //logString(String(nRetry))
                    nRetry += 1
                    sleep(1)//每隔1s重新发送请求信息
                }
                else//tls阶段
                {
                    if(nTLS>=timeTLS)
                    {
         
                        
                        self.session?.writeMultipleDatagrams(self.sslVPN.readControlChannel(), completionHandler: { (error) in
                          self.addMessageToArray("TLS Phase : ERROR ", message: String(error.debugDescription))
                         

                            
                        })
                        nTLS=0
                        nRetry += 1
                    }
                    else
                    {
                        nTLS += timeTLS
                        sleep(timeTLS)
                    }
                }
            }
            else//已经连接，超时检测
            {
                //ping-restart
                if(nPingRestart>=timePingRestart)
                {
                    if(UInt32(NSDate().timeIntervalSinceDate(timeRec)) >= timePingRestart) //超时，重新连接
                    {
//                      self.addMessageToArray("ERROR : ", message:"-------------------------------------------")
//                
                                  let ca  = (self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
                              let autoReconnect =  ca["reConnect"] as! String
                        
                       
                            
                                                    nTLS=0
                                                    nRetry=0
                                                    nPingRestart=0
                                                    isConnected=false
                         if (autoReconnect == "reConnect" ){
                                                    sslVPN.restart()
                                                    self.session?.writeMultipleDatagrams(self.sslVPN.readControlChannel(), completionHandler: { (error) in
                                                        if error != nil {
                                                            self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                                                        }
                                                        })
                         
                            continue
                         }else{
                            self.sslVPN.state = SSLVPNState.Error
                        }

                        
                    }
                    else
                    {   nPingRestart=0    }
                }
                //ping
                 self.session?.writeMultipleDatagrams(self.sslVPN.encryptDataChannel([dataPing]), completionHandler: { (error) in
               
                    if error != nil {
                        self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                    }

                    
                 })
                
               
                nPingRestart += timePing
                sleep(timePing)
            }
            
        }
        
    }
    
    func addMessageToArray(headerMessage: String , message: String) -> Void{
        
        
        let df=NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss "
        let  strTimeConnect=df.stringFromDate(NSDate())
        .stringByAppendingString(String(headerMessage))
        
        let message =   strTimeConnect.stringByAppendingString(String(message))
       let endMessage  = message.stringByAppendingString(String("\n"))
        
//        self.messageArray.append(endMessage)
//        
//        if self.messageArray.count > 1000 {
//            
//        self.messageArray.removeFirst()
//        }
        
        

         }
    
    //开始VPN连接
    override func startTunnelWithOptions(options: [String : NSObject]?, completionHandler: (NSError?) -> Void)
    {
        

//        [[FileWatcher shared] startManager];
        
        countSend=0
     
        countRec=0
        //检测用户名,密码
       
    
       let messageHeader =  String.init(format: "User Info: username %@  password [...]", self.protocolConfiguration.username!)
        self.addMessageToArray(messageHeader, message: String(""))
        
        if(self.protocolConfiguration.username==nil || self.protocolConfiguration.passwordReference==nil)
        {
            completionHandler(NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"No username or password"]))
            
            self.addMessageToArray("ERROR:No username or password", message: String(""))
            return
        }
        
        sslVPN.addMessage = {  message   in
            
            self.addMessageToArray("SSLVPN State : ", message: String(message))
        }
        //启动OpenVPN
        if(!sslVPN.restart(self.protocolConfiguration.username!, password:String.init(data: self.protocolConfiguration.passwordReference!, encoding: NSASCIIStringEncoding)!, configuration: (self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!))
        {
            
         
            
            completionHandler(NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"OpenVPN library init wrong"]))
            self.addMessageToArray("ERROR:OpenVPN library init wrong", message: String(""))
            
            return
        }
        
        
        
       
        
                //启动插件
        if let serverAddress = self.protocolConfiguration.serverAddress
        {
            ipAdress = HostToIP.getIP(serverAddress)
            //开始连接服务器
            
            

        session = self.createUDPSessionToEndpoint(NWHostEndpoint(hostname: ipAdress!, port:"10442"), fromEndpoint: nil)
            
            
            self.readPacketsFromUDP()
            self.session?.writeMultipleDatagrams(self.sslVPN.readControlChannel(), completionHandler: { (error) in
                
                if error != nil {
                    self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                }

            })
            //检测初始连接状态
                 threadConnect=NSThread(target: self, selector: #selector(PacketTunnelProvider.testConnect(_:)), object: nil)
            
            threadConnect?.start()
            
        
            self.pendingStartCompletion = completionHandler
        }
        else
        {
            
               self.addMessageToArray("ERROR :Configuration is missing serverAddress ", message: String(""))
            completionHandler(NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"Configuration is missing serverAddress"]))
        
        }
    }

     func stopTunnel(reason: NEProviderStopReason, completionHandler: () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        
        pendingInformationCompletion = nil
        pendingStartCompletion=nil
        pendingStopCompletion = completionHandler
        session?.cancel()
        threadConnect?.cancel()
        
        self.addMessageToArray("Tunnel Has stopped", message: String(""))
        completionHandler()
    }

    
    
    //处理IPC消息
    override func handleAppMessage(messageData: NSData, completionHandler: ((NSData?) -> Void)?)
    {
       
        guard let messageString = NSString(data: messageData, encoding: NSUTF8StringEncoding)
            else
        {   completionHandler?(nil);return  }
        //
      
        self.pendingInformationCompletion = completionHandler
        
        switch(messageString)
        {
            
        case "ip":if(sslVPN.netSetting.adressIpList.count>0){completionHandler?((sslVPN.netSetting.adressIpList[0] as! String).dataUsingEncoding(NSUTF8StringEncoding))} else{completionHandler?(("null").dataUsingEncoding(NSASCIIStringEncoding))}
        case "time":completionHandler?(sslVPN.strTimeConnect.dataUsingEncoding(NSUTF8StringEncoding))
       
            
        case "DNS":
        
            
            for  i  in 0 ..< sslVPN.netSetting.dnsList.count {
                
                self.DNSString!.appendString(sslVPN.netSetting.dnsList[i] as! String)
                self.DNSString?.appendString(",")
            }
         
            
            completionHandler?(self.DNSString!.dataUsingEncoding(NSUTF8StringEncoding))
   
            self.DNSString  = NSMutableString()
            
        case "packet":completionHandler?((String(countSend)+"|"+String(countRec)).dataUsingEncoding(NSUTF8StringEncoding))
        case "state":completionHandler?((String(sslVPN.state)).dataUsingEncoding(NSUTF8StringEncoding))
        case "reConnecting":completionHandler?((String(sslVPN.netSetting.reConnecting)).dataUsingEncoding(NSUTF8StringEncoding))
            
        case "dataChannel":completionHandler?((String(sslVPN.dataChannel.pid)).dataUsingEncoding(NSUTF8StringEncoding))
        case "debug1":completionHandler?((String(sslVPN.controlChannel.outPacketList.count)+"|"+String(sslVPN.controlChannel.inPacketList.count)).dataUsingEncoding(NSUTF8StringEncoding))
//            case "debug2":
//                
//            for  i  in 0 ..< self.messageArray.count {
//            
//            self.errorMessage?.appendString(self.messageArray[i] as! String)
//        }
//            let string = self.errorMessage
//            
//            completionHandler?(string!.dataUsingEncoding(NSUTF8StringEncoding))
//
            
           case "pingRestart":completionHandler?((String(sslVPN.netSetting.pingRestart)).dataUsingEncoding(NSUTF8StringEncoding))
        default:completionHandler?(("no answer").dataUsingEncoding(NSUTF8StringEncoding))
            
            
        }
        
        
        
        
    }
    
    //休眠
    override func sleepWithCompletionHandler(completionHandler: () -> Void)
    {   completionHandler()     }
    
    //唤醒
    override func wake()
    {   }
    
    //从网卡读取数据
    func readPacketsFromTUN()
    {
        self.packetFlow.readPacketsWithCompletionHandler
            { packets, protocols in
                let dataList=self.sslVPN.encryptDataChannel(packets);
                //self.countSend += dataList.count
                //self.logNsdataList(packets)
                //self.logNsdataList(dataList)
                //加密并通过隧道发送给服务器
                       self.session?.writeMultipleDatagrams(dataList, completionHandler: { (error) in
                        if error != nil {
                            self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                        }

                        
                       })
                
                
                self.readPacketsFromTUN()
        }
    }
    
    //从UDP处读取
    func readPacketsFromUDP()
    {
        self.addMessageToArray("STAGE : Read Packets From UDP ", message: String(""))
        
        
        session?.setReadHandler(
            {(newPackets: [NSData]?, error: NSError?) -> Void in
                guard let packets = newPackets else { return }
                //写入数据,由openvpn自行判断写入通道
                self.sslVPN.write(packets)
                //控制通道，发送回服务器
                let dataControl=self.sslVPN.readControlChannel()
                self.session?.writeMultipleDatagrams(dataControl, completionHandler: { (error ) in
                    if error != nil {
                        self.addMessageToArray("ERROR : ", message: String(error.debugDescription))
                     }
                    
                

             
                })
                //配置并完全展开VPN
                if(!self.isConnected && self.sslVPN.state==SSLVPNState.Active)
                {
                    self.isConnected=true
                    self.countRec = 0
                    self.countSend = 0
                    self.updateNetwork()
                }
                //数据通道，写入网卡
                var protocols = [NSNumber]()
                let decryptedPackets = self.sslVPN.readDataChannel()
                for _ in 0 ..< decryptedPackets.count
                { protocols.append(2) }
                //统计数据
                self.timeRec = NSDate()
                self.countRec += packets.count
                self.countSend += decryptedPackets.count+dataControl.count
                //debug
//                self.logNsdataList(packets)
                //self.logNsdataList(decryptedPackets)
                //self.debug()
                self.packetFlow.writePackets(decryptedPackets, withProtocols: protocols)},maxDatagrams: 1024)
    }
    
    //网络配置
    func updateNetwork()
    {
        //时间参数配置,在更新ovpn文件后加入
        //新配置
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: ipAdress!)
        newSettings.IPv4Settings = NEIPv4Settings(addresses:self.sslVPN.netSetting.adressIpList as! [String], subnetMasks:self.sslVPN.netSetting.adressMasksList as! [String])
        newSettings.MTU = 1500
        newSettings.tunnelOverheadBytes = 150
        //路由
        if(self.sslVPN.netSetting.routeIpList.count>0)
        {
            let routeIpList=self.sslVPN.netSetting.routeIpList as! [String]
            let routeMasksList=self.sslVPN.netSetting.routeMasksList as! [String]
            var includedRoutes = [NEIPv4Route]()
            for i in 0 ..< routeIpList.count
            {   includedRoutes.append(NEIPv4Route(destinationAddress: routeIpList[i], subnetMask:routeMasksList[i]))   }
            newSettings.IPv4Settings!.includedRoutes = includedRoutes
        }
        else
        {   newSettings.IPv4Settings!.includedRoutes = [NEIPv4Route.defaultRoute()]    }
        
        
        let ca  = (self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        let doMains =  ca["doMains"] as! NSArray

        //DNS
        newSettings.DNSSettings = NEDNSSettings(servers:(self.sslVPN.netSetting.dnsList as! [String]))
        newSettings.DNSSettings!.matchDomains  = doMains as! [String];
        
        //ping
        if(sslVPN.netSetting.ping>5)
        {timePing=UInt32(sslVPN.netSetting.ping)}
        if(sslVPN.netSetting.pingRestart>60)
        {timePingRestart=UInt32(sslVPN.netSetting.pingRestart)}
        //更新配置并开始从网卡读取数据
        
        self.setTunnelNetworkSettings(newSettings)
            { (error: NSError?) -> Void in
                if let completionHandler = self.pendingStartCompletion
                {
                    
                    completionHandler(error)
                    if (error == nil)
                    {   self.readPacketsFromTUN()   }
                    else
                    {   exit(0)     }
                }
        }
    }
    
    
    var isDebug=true
    func debug()
    {
        if(!isDebug)
        {return}
        //        if(sslVPN.dataNetSetting.length>0)
        //        {
        //             //self.logNsdata(sslVPN.dataMasterSecret)
        //            self.logNsdata(sslVPN.dataNetSetting)
        //            
        //            isDebug = false
        //        }
        //        self.logString(String(self.sslVPN.state))
    }
    
}
