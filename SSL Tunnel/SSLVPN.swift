//
//  OpenVPNLayer.swift
//  SSL VPN
//
//  Created by shijia on 15/10/12.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation
 typealias AddMessageBlock = (message:String)->Void
class SSLVPN
{
    //数据
    var sessionServer:NSData = NSData()
    var sessionCilent:NSData = NSData()
    var dataNetSetting:NSData = NSData()
    var dataOptionServer:NSData = NSData()
    var dataOptionClient:NSData = NSData()
    var dataMasterSecret:NSData = NSData()
    
    var testData = [NSData()]
    var controlChannel = ControlChannel()
    var dataChannel = DataChannel()
    var state = SSLVPNState.Initial
    var strUserName=""
    var strPassword=""
    var strTimeConnect="00:00:00"
    var dataCa=NSDictionary()
    var netSetting=NetSetting()
    var addMessage = AddMessageBlock?()
   
    
    //复位
    func restart(username:String,password:String,configuration:[String:AnyObject])->Bool
    {
        strUserName=username
        strPassword=password
        let ca=configuration
        if(ca.values.count != 0)
        {   dataCa=ca    }
        else
        {   dataCa=NSDictionary()    }
        return restart()
    }
    func restart(username:String,password:String)->Bool
    {
        strUserName=username
        strPassword=password
        return restart()
    }
    func restart()->Bool
    {
        
        NSLog("1111111111111111111111111")
        
        var intSession = arc4random()
        netSetting=NetSetting()
        sessionCilent  = NSData(bytes: &intSession, length: 8)
        state = SSLVPNState.Initial
        dataOptionServer = NSData()
        dataNetSetting = NSData()
        dataMasterSecret = NSData()
        dataOptionClient=creatOptionClient()
        controlChannel = ControlChannel()
        dataChannel = DataChannel()
        strTimeConnect="00:00:00"
        netSetting=NetSetting()
        
        controlChannel.conChannelMessage = {  message   in
            
            
            self.addMessage!(message: message)
            
            
        }
        return controlChannel.restart(dataCa as! [String : AnyObject])
    }
    
    //创建密钥数据
    private func creatOptionClient()->NSData
    {
        let data:NSMutableData=NSMutableData()
        var bytesHead:[UInt8]=[0x0, 0x0, 0x0, 0x0, 0x2]
        data.appendBytes(&bytesHead, length: bytesHead.count)
        for _ in 0 ..< 28
        {
            var intSession = arc4random()
            data.appendBytes(&intSession, length: 4)
        }
        //data.appendData(stringToNsdata("V4,dev-type tun,link-mtu 1541,tun-mtu 1500,proto UDPv4,cipher BF-CBC,auth SHA1,keysize 128,key-method 2,tls-client"))
        data.appendData(stringToNsdata("V4,dev-type tun,link-mtu 1542,tun-mtu 1500,proto UDPv4,comp-lzo,cipher BF-CBC,auth SHA1,keysize 128,key-method 2,tls-client"))
        if(!strUserName.isEmpty && !strPassword.isEmpty)
        {
            data.appendData(stringToNsdata(strUserName))
            data.appendData(stringToNsdata(strPassword))
        }
        data.appendBytes(&bytesHead, length: 1)
        return data
    }
    
    //硬重启(客服端)
    func restartData()->NSData
    {
        let data:NSMutableData=NSMutableData()
        data.appendData(NSData(bytes:[SSLVPNOpcode.HardResetClient.opcode<<3], length:1))
        data.appendData(sessionCilent)
        data.appendData(dataExt)
        return data
    }
    
    //状态切换,不同于openvpn
    private func nextState()->[NSData]
    {
        if(state == SSLVPNState.Initial)
        {
            
            self.addMessage!(message: String(SSLVPNState.Initial))
            return [restartData()]
        }
        //
        if(state == SSLVPNState.PerStart)
        {
             self.addMessage!(message: String(SSLVPNState.PerStart))
           
            
            controlChannel.doSSLRead()
            
            
           
 
            
            if(self.controlChannel.isHandShake())
            {
                
                   self.addMessage!(message: String(SSLVPNState.Start))
                
                state=SSLVPNState.Start
                controlChannel.encryptNSData(dataOptionClient)
            }
            
            
            return readControlChannel(false)
        }
        //
        if(state == SSLVPNState.Start)
        { self.addMessage!(message: String(SSLVPNState.Start))
            state=SSLVPNState.SendKey
        }
        //
        if(state == SSLVPNState.SendKey)
        {
            self.addMessage!(message: String(SSLVPNState.SendKey))
            dataOptionServer = controlChannel.readDecrypt()
            if(dataOptionServer.length>0)
            {
                state=SSLVPNState.GotKey
                controlChannel.encryptNSData(dataPushRequset)
                dataMasterSecret=MasterSecret.creatMasterSecret(dataOptionClient, optionServer: dataOptionServer, sessionClient: sessionCilent, sessionServer: sessionServer)
                dataChannel.restart(dataMasterSecret)
            }
            return readControlChannel(false)
        }
        //
        if(state == SSLVPNState.GotKey)
        {
            
            self.addMessage!(message: String(SSLVPNState.GotKey))
            state=SSLVPNState.PushRequest
        }
        //
        if(state == SSLVPNState.PushRequest)
        {
                   self.addMessage!(message: String(SSLVPNState.PushRequest))
            if(netSetting.add(controlChannel.readDecrypt()))
            {
                let df=NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                strTimeConnect=df.stringFromDate(NSDate())
                state = SSLVPNState.Active
                
            }
            return readControlChannel(false)
        }
        //
        if(state == SSLVPNState.GotReply)
        {
             self.addMessage!(message: String(SSLVPNState.GotReply))
            state=SSLVPNState.Active
        }
        //
        if(state == SSLVPNState.Active)
        {
             self.addMessage!(message: String(SSLVPNState.Active))
        }
        return [NSData]()
    }
    
    //写入
    func write(packets:[NSData])
    {
     
        
        var packetListControl:[PacketControl] = [PacketControl]()
        var packetListData:[NSData] = [NSData]()
        for p in packets
        {
            switch  UnsafePointer<UInt8>(p.bytes).memory>>3
            {
            case SSLVPNOpcode.Control.opcode:
                
                
                packetListControl.append(decryptControlChannel(p))
          
                
            case SSLVPNOpcode.Ack.opcode:
                
                
                packetListControl.append(decryptControlChannel(p))
                
                
            case SSLVPNOpcode.DataV1.opcode:
                
                
                packetListData.append(p)
                
                
            case SSLVPNOpcode.HardResetServer.opcode:
               
                
                state = SSLVPNState.PerStart
                sessionServer=p.subdataWithRange(NSMakeRange(1, 8));
                packetListControl.append(decryptControlChannel(p))
                controlChannel.write(packetListControl);
                
                
                
                return
            default :
                
                continue
            }
        }
        //写入控制通道
        controlChannel.write(packetListControl)
        //写入数据通道
        dataChannel.write(packetListData)
    }
    
    ////////////////////////////////////////////////////////////////////////
    //////////////////////////////控制通道///////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    //读取控制通道
    func readControlChannel()->[NSData]
    {
            
        return readControlChannel(true)
    
    
    }
    private  func readControlChannel(isWithState:Bool)->[NSData]
    {
        //状态机切换
        if(isWithState)
        {
            if(state != SSLVPNState.Active && controlChannel.isFullSync())
            {   return nextState()  }
        }
        //控制通道数据,用于写入UDP
        let packetList=controlChannel.read()
        var dataList:[NSData]=[NSData]()
        for i in 0 ..< packetList.count
        {  dataList.append(encryptControlChannel(packetList[i])) }
        return dataList
    }
    
    //打包-控制通道
    func encryptControlChannel(packetList:[PacketControl])->[NSData]
    {
        var dataList:[NSData]=[NSData]()
        for i in 0 ..< packetList.count
        {  dataList.append(encryptControlChannel(packetList[i])) }
        return dataList
    }
    func encryptControlChannel(packet:PacketControl)->NSData
    {
        var pidBigEndian=packet.id.bigEndian
        let data:NSMutableData=NSMutableData()
        data.appendData(NSData(bytes:[packet.opcode<<3], length:1))
        data.appendData(sessionCilent)
        if(packet.opcode == SSLVPNOpcode.Ack.opcode)
        {
            data.appendData(data01)
            data.appendData(NSData(bytes: &pidBigEndian, length: 4))
            data.appendData(sessionServer)
        }
        else if(packet.tid==0)
        {
            data.appendData(data00)
            data.appendData(NSData(bytes: &pidBigEndian, length: 4))
            data.appendData(packet.data)
        }
        else
        {
            var tidBigEndian=packet.tid.bigEndian
            data.appendData(data01)
            data.appendData(NSData(bytes: &tidBigEndian, length: 4))
            data.appendData(sessionServer)
            data.appendData(NSData(bytes: &pidBigEndian, length: 4))
            data.appendData(packet.data)
        }
        return data
    }
    
    //解包-控制通道
    func decryptControlChannel(data:NSData)->PacketControl
    {
        let opcode:UInt8=UnsafePointer<UInt8>(data.bytes).memory>>3
        var id:UInt32=0
        var length=14
      NSLog("+++++++++++++++++%@",String(data.length) )
        if( UnsafePointer<UInt8>(data.bytes+9).memory == 0x01  && data.length >= 26)//包序列
        {  length=26
            
            
            data.getBytes(&id, range: NSMakeRange(length-4, 4))
            
        }else{
            data.getBytes(&id, range: NSMakeRange(length-4, 4))
        }
        
 
        let data:NSData=data.subdataWithRange(NSMakeRange(length,data.length-length))
        
        return PacketControl(Opcode: opcode, ID: id.bigEndian, Data: data)
    }
    
    ////////////////////////////////////////////////////////////////////////
    //////////////////////////////数据通道///////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    //读取-数据通道
    func readDataChannel()->[NSData]
    {
        
        return self.dataChannel.read()   }
    
    //加密-数据通道
    func encryptDataChannel(packets:[NSData])->[NSData]
        
    {   return dataChannel.encryptData(packets)     }
    
    //解密-数据通道
    func decryptDataChannel(packets:[NSData])->[NSData]
    {   return dataChannel.decryptData(packets)     }
    
}
