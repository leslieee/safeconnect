//
//  OpenVPNLayer.swift
//  SSL VPN
//
//  Created by shijia on 15/10/12.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation
// typealias AddMessageBlock = (message:String)->Void
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
	var addMessage: ((String)->Void)?
   
    
    //复位
    func restart(username:String,password:String,configuration:[String:AnyObject])->Bool
    {
        strUserName=username
        strPassword=password
        let ca=configuration
        if(ca.values.count != 0)
        {   dataCa=ca as NSDictionary    }
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
            
            
            self.addMessage!(message)
            
            
        }
        return controlChannel.restart(dataCa: dataCa as! [String : AnyObject] as NSDictionary)
    }
    
    //创建密钥数据
    private func creatOptionClient()->NSData
    {
        let data:NSMutableData=NSMutableData()
        var bytesHead:[UInt8]=[0x0, 0x0, 0x0, 0x0, 0x2]
        data.append(&bytesHead, length: bytesHead.count)
        for _ in 0 ..< 28
        {
            var intSession = arc4random()
            data.append(&intSession, length: 4)
        }
        //data.appendData(stringToNsdata("V4,dev-type tun,link-mtu 1541,tun-mtu 1500,proto UDPv4,cipher BF-CBC,auth SHA1,keysize 128,key-method 2,tls-client"))
        data.append(stringToNsdata(str: "V4,dev-type tun,link-mtu 1542,tun-mtu 1500,proto UDPv4,comp-lzo,cipher BF-CBC,auth SHA1,keysize 128,key-method 2,tls-client") as Data)
        if(!strUserName.isEmpty && !strPassword.isEmpty)
        {
            data.append(stringToNsdata(str: strUserName) as Data)
            data.append(stringToNsdata(str: strPassword) as Data)
        }
        data.append(&bytesHead, length: 1)
        return data
    }
    
    //硬重启(客服端)
    func restartData()->NSData
    {
        let data:NSMutableData=NSMutableData()
        data.append(NSData(bytes:[SSLVPNOpcode.HardResetClient.opcode<<3], length:1) as Data)
        data.append(sessionCilent as Data)
        data.append(dataExt as Data)
        return data
    }
    
    //状态切换,不同于openvpn
    private func nextState()->[NSData]
    {
        if(state == SSLVPNState.Initial)
        {
            
            self.addMessage!(String(describing: SSLVPNState.Initial))
            return [restartData()]
        }
        //
        if(state == SSLVPNState.PerStart)
        {
             self.addMessage!(String(describing: SSLVPNState.PerStart))
           
            
            controlChannel.doSSLRead()
            
            
           
 
            
            if(self.controlChannel.isHandShake())
            {
                
                   self.addMessage!(String(describing: SSLVPNState.Start))
                
                state=SSLVPNState.Start
                controlChannel.encryptNSData(data: dataOptionClient)
            }
            
            
            return readControlChannel(isWithState: false)
        }
        //
        if(state == SSLVPNState.Start)
        { self.addMessage!(String(describing: SSLVPNState.Start))
            state=SSLVPNState.SendKey
        }
        //
        if(state == SSLVPNState.SendKey)
        {
            self.addMessage!(String(describing: SSLVPNState.SendKey))
            dataOptionServer = controlChannel.readDecrypt()
            if(dataOptionServer.length>0)
            {
                state=SSLVPNState.GotKey
                controlChannel.encryptNSData(data: dataPushRequset)
                dataMasterSecret=MasterSecret.creatMasterSecret(dataOptionClient as Data!, optionServer: dataOptionServer as Data!, sessionClient: sessionCilent as Data!, sessionServer: sessionServer as Data!)! as NSData
                let _ = dataChannel.restart(data: dataMasterSecret)
            }
            return readControlChannel(isWithState: false)
        }
        //
        if(state == SSLVPNState.GotKey)
        {
            
            self.addMessage!(String(describing: SSLVPNState.GotKey))
            state=SSLVPNState.PushRequest
        }
        //
        if(state == SSLVPNState.PushRequest)
        {
                   self.addMessage!(String(describing: SSLVPNState.PushRequest))
            if(netSetting?.add(controlChannel.readDecrypt() as Data!))!
            {
                let df=DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                strTimeConnect=df.string(from: NSDate() as Date)
                state = SSLVPNState.Active
                
            }
            return readControlChannel(isWithState: false)
        }
        //
        if(state == SSLVPNState.GotReply)
        {
             self.addMessage!(String(describing: SSLVPNState.GotReply))
            state=SSLVPNState.Active
        }
        //
        if(state == SSLVPNState.Active)
        {
             self.addMessage!(String(describing: SSLVPNState.Active))
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
            switch  UnsafePointer<UInt8>(p.bytes.assumingMemoryBound(to: UInt8.self)).pointee>>3
            {
            case SSLVPNOpcode.Control.opcode:
                
                
                packetListControl.append(decryptControlChannel(data: p))
          
                
            case SSLVPNOpcode.Ack.opcode:
                
                
                packetListControl.append(decryptControlChannel(data: p))
                
                
            case SSLVPNOpcode.DataV1.opcode:
                
                
                packetListData.append(p)
                
                
            case SSLVPNOpcode.HardResetServer.opcode:
               
                
                state = SSLVPNState.PerStart
                sessionServer=p.subdata(with: NSMakeRange(1, 8)) as NSData;
                packetListControl.append(decryptControlChannel(data: p))
                controlChannel.write(packetList: packetListControl);
                
                
                
                return
            default :
                
                continue
            }
        }
        //写入控制通道
        controlChannel.write(packetList: packetListControl)
        //写入数据通道
        dataChannel.write(packets: packetListData)
    }
    
    ////////////////////////////////////////////////////////////////////////
    //////////////////////////////控制通道///////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    //读取控制通道
    func readControlChannel()->[NSData]
    {
            
        return readControlChannel(isWithState: true)
    
    
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
        {  dataList.append(encryptControlChannel(packet: packetList[i])) }
        return dataList
    }
    
    //打包-控制通道
    func encryptControlChannel(packetList:[PacketControl])->[NSData]
    {
        var dataList:[NSData]=[NSData]()
        for i in 0 ..< packetList.count
        {  dataList.append(encryptControlChannel(packet: packetList[i])) }
        return dataList
    }
    func encryptControlChannel(packet:PacketControl)->NSData
    {
        var pidBigEndian=packet.id.bigEndian
        let data:NSMutableData=NSMutableData()
        data.append(NSData(bytes:[packet.opcode<<3], length:1) as Data)
        data.append(sessionCilent as Data)
        if(packet.opcode == SSLVPNOpcode.Ack.opcode)
        {
            data.append(data01 as Data)
            data.append(NSData(bytes: &pidBigEndian, length: 4) as Data)
            data.append(sessionServer as Data)
        }
        else if(packet.tid==0)
        {
            data.append(data00 as Data)
            data.append(NSData(bytes: &pidBigEndian, length: 4) as Data)
            data.append(packet.data as Data)
        }
        else
        {
            var tidBigEndian=packet.tid.bigEndian
            data.append(data01 as Data)
            data.append(NSData(bytes: &tidBigEndian, length: 4) as Data)
            data.append(sessionServer as Data)
            data.append(NSData(bytes: &pidBigEndian, length: 4) as Data)
            data.append(packet.data as Data)
        }
        return data
    }
    
    //解包-控制通道
    func decryptControlChannel(data:NSData)->PacketControl
    {
        let opcode:UInt8=UnsafePointer<UInt8>(data.bytes.assumingMemoryBound(to: UInt8.self)).pointee>>3
        var id:UInt32=0
        var length=14
      NSLog("+++++++++++++++++%@",String(data.length) )
        if( UnsafePointer<UInt8>(data.bytes.assumingMemoryBound(to: UInt8.self)+9).pointee == 0x01  && data.length >= 26)//包序列
        {  length=26
            
            
            data.getBytes(&id, range: NSMakeRange(length-4, 4))
            
        }else{
            data.getBytes(&id, range: NSMakeRange(length-4, 4))
        }
        
 
        let data:NSData=data.subdata(with: NSMakeRange(length,data.length-length)) as NSData
        
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
        
    {   return dataChannel.encryptData(packets: packets)     }
    
    //解密-数据通道
    func decryptDataChannel(packets:[NSData])->[NSData]
    {   return dataChannel.decryptData(packets: packets)     }
    
}
