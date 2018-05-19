//
//  ReliabilityLayer.swift
//  SSL VPN
//
//  Created by shijia on 15/10/9.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation
typealias ControlChannelAddMessageBlock = (message:String)->Void

class ControlChannel
{
    var tid:UInt32=0
    var pid:UInt32=1
    var idRec:UInt32=1
    let mtu:Int=1000
    let sslLayer = SSLLayer()
    var inPacketList:[PacketControl]=[PacketControl]()
    var outPacketList:[PacketControl]=[PacketControl]()
    var ackPacketList:[PacketControl]=[PacketControl]()
    var conChannelMessage = ControlChannelAddMessageBlock?()
    func restart(dataCa:NSDictionary)->Bool
    {
        tid=0
        pid=1
        idRec=1
        inPacketList=[PacketControl]()
        
       
        outPacketList=[PacketControl]()
        
        sslLayer.sslLayerMesssage = {  message   in
            
            self.conChannelMessage!(message: message);
            
        }
        return sslLayer.restart(dataCa as [NSObject : AnyObject])
    }
    
    func restart()->Bool
    {
        tid=0
        pid=1
        idRec=1
        inPacketList=[PacketControl]()
        outPacketList=[PacketControl]()
        
      
        
        
        return sslLayer.restart(NSDictionary() as [NSObject : AnyObject])
    }
    //完成握手
    func isHandShake()->Bool
    {
        if(outPacketList.isEmpty && sslLayer.isHandShake())
        {
           
            
            
            if  (self.conChannelMessage != nil) {
                self.conChannelMessage!(message: "ControlChannel Handshake finished");

            }
            
            
            return true
        
        }
        else
        {
            
     
            
            if  (self.conChannelMessage != nil) {
                self.conChannelMessage!(message: "ControlChannel Handshake Failed");
                
            }
            
            
            
            
            return false
        
        }
    }
    //完成同步
    func isFullSync()->Bool
    {
        //ackPacketList.isEmpty,不同于openvpn
        if(inPacketList.isEmpty &&  outPacketList.isEmpty)
        {   return true   }
        else
        {   return false   }
    }
    
    //进行读取
    func doSSLRead()
    {   dataToBuffer(readSSLBIO())  }
    
    //从ssl读取控制数据
    private func readSSLBIO()->NSData
    {
        let data:NSMutableData=NSMutableData()
        var dataRead:NSData = sslLayer.read()
        while(dataRead.length>0)
        {
            data.appendData(dataRead)
            dataRead = sslLayer.read()
        }
        return data
    }
    
    //数据写入缓存
    func dataToBuffer(data:NSData)
    {
        if(data.length <= mtu || pid==1)
        {
            var offset=0
            while(offset < data.length)
            {
                let dataP:NSData=data.subdataWithRange(NSMakeRange(offset,min(mtu, data.length-offset)))
                outPacketList.append(PacketControl(Opcode: SSLVPNOpcode.Control.opcode, ID: pid, Data: dataP))
                pid += 1
                tid += 1
                offset += mtu
            }
        }
        else
        {
            outPacketList.append(PacketControl(Opcode: SSLVPNOpcode.Control.opcode, ID: pid, TID: tid, Data: data.subdataWithRange(NSMakeRange(0,mtu))))
            var offset=mtu
            pid += 1
            tid += 1
            while(offset < data.length)
            {
                let dataP:NSData=data.subdataWithRange(NSMakeRange(offset,min(mtu, data.length-offset)))
                outPacketList.append(PacketControl(Opcode: SSLVPNOpcode.Control.opcode, ID: pid, Data: dataP))
                pid += 1
                tid += 1
                offset += mtu
            }
        }
    }
    
    //读取
    func read()->[PacketControl]
    {
        let r=ackPacketList+outPacketList
        outPacketList.removeAll()//未加入时间函数
        ackPacketList.removeAll()//发送既清空
        return r
    }
    
    func readAck()->[PacketControl]
    {   return readAck(true)    }
    func readAck(isClear:Bool)->[PacketControl]
    {
        let r=ackPacketList
        if(isClear)
        {   ackPacketList.removeAll()   }
        return r
    }
    
    func readBuffer()->[PacketControl]
    {   return readBuffer(true)    }
    func readBuffer(isClear:Bool)->[PacketControl]
    {
        let r=outPacketList
        if(isClear)
        {   outPacketList.removeAll()   }
        return r
    }
    
    //写入
    func write(packetList:[PacketControl])
    {
        writeToBuffer(packetList)
        writeToSSL()
    }
    //写入缓存
    private func writeToBuffer(packetList:[PacketControl])
    {
        for p in packetList
        {
            switch  p.opcode
            {
            case SSLVPNOpcode.Ack.opcode: removePacket(p.id)
            case SSLVPNOpcode.Control.opcode:insert(p);ackPacketList.append(PacketControl(ID: p.id, TID: tid));tid += 1;
            case SSLVPNOpcode.HardResetServer.opcode : ackPacketList.append(PacketControl(ID: p.id, TID: tid));tid += 1;
            default:continue
            }
        }
    }
    //写入ssl
    private func writeToSSL()
    {
        
        
    
        
        
        //符合队列的数据写入ssl
        var n=0
        while n<inPacketList.count
        {
            if(inPacketList[n].id != idRec)
            {break}
            sslLayer.write(inPacketList[n].data);
            idRec += 1
            n += 1
        }
        //清除写入缓存的数据
        while n>0
        {
            n -= 1
            inPacketList.removeAtIndex(n)
        }
        //老版，稳定版
        ////符合队列的数据写入ssl
        //for(n=0;n<inPacketList.count;n += 1)
        //{
        //    if(inPacketList[n].id != idRec)
        //    {break}
        //    sslLayer.write(inPacketList[n].data);
        //    idRec += 1
        //}
        ////清除写入缓存的数据
        //for(n -= 1;n >= 0;n -= 1)
        //{ inPacketList.removeAtIndex(n) }
    }
    
    
    //插入数据包,自动排序
    private func insert(p:PacketControl)
    {
        //已经接收的包,抛弃
        if(p.id<self.idRec)
        {return}
        //插入
        var i=inPacketList.count-1
        while i>=0
        {
            if(p.id==inPacketList[i].id)
            {return}
            if(p.id>inPacketList[i].id)
            {
                inPacketList.insert(p, atIndex: i+1)
                return
            }
            i -= 1
        }
        //若是最小数据,插入到首位
        inPacketList.insert(p, atIndex: 0)
        //老版，稳定版
        ////插入
        //for(var i=inPacketList.count-1;i >= 0;i -= 1)
        //{
        //    if(p.id==inPacketList[i].id)
        //    {return}
        //    if(p.id>inPacketList[i].id)
        //    {
        //        inPacketList.insert(p, atIndex: i+1)
        //        //self.inID.append(p.id);
        //        return
        //    }
        //}
        ////若是最小数据,插入到首位
        //inPacketList.insert(p, atIndex: 0)
    }
    //清除已经确认的包
    private func removePacket(idPacket:UInt32)
    {
        for i in 0 ..< outPacketList.count
        {
            if(outPacketList[i].id==idPacket)
            {
                outPacketList.removeAtIndex(i)
                return
            }
        }
    }
    
    //加密
    func encryptNSData(data:NSData)
    {
        let dataEncrypt=sslLayer.encryptNSData(data)
        dataToBuffer(dataEncrypt)
    }
    
    //读取解密
    func readDecrypt()->NSData
    {
        let data:NSMutableData=NSMutableData()
        var dataRead:NSData = sslLayer.readDecrypt()
        while(dataRead.length>0)
        {
            data.appendData(dataRead)
            dataRead = sslLayer.read()
        }
        return data
    }
    
    
    
}
