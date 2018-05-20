//
//  DataChannel.swift
//  SSL VPN
//
//  Created by shijia on 15/10/30.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation
//功能实现,逻辑细节待调整
//压缩很影响速度

class DataChannel
{
    var pid:UInt32=1
    var idRec:UInt32=0
    var outPacketList:[NSData]=[NSData]()//输出未解密的数据，用于写入网卡
    //var inPacketList:[NSData]=[NSData]()//输入的数据
    let crypto=Crypto()
    let lzo=Lzo()
    
    func restart(data:NSData)->Bool
    {
        pid=1
        idRec=0
        outPacketList=[NSData]()
        return crypto.restart(data as Data!)
    }
    //加密
    func encryptData(packets:[NSData])->[NSData]
    {
        var dataList=[NSData]()
        for p in packets
        {   dataList.append(encryptData(p: p))   }
        return dataList
    }
    func encryptData(p:NSData)->NSData
    {
        var pidBigEndian=pid.bigEndian
        let data:NSMutableData=NSMutableData()
        data.append(NSData(bytes: &pidBigEndian, length: 4) as Data)
        let dataEncrypt:NSMutableData=NSMutableData()
        dataEncrypt.append(NSData(bytes:[SSLVPNOpcode.DataV1.opcode<<3], length:1) as Data)
//        //不启动压缩，防止影响速度
//        data.appendData(dataNocompress)
//        data.appendData(p)
//        dataEncrypt.appendData(crypto.encryptData(data))
        //常规模式
        if(p.length<100)//不压缩
        {
            data.append(dataNocompress as Data)
            data.append(p as Data)
            dataEncrypt.append(crypto.encryptData(data as Data!))
        }
        else//压缩
        {
            data.append(dataCompress as Data)
            data.append((lzo?.compressNSData(p as Data!))!)
            dataEncrypt.append(crypto.encryptData(data as Data!))
        }
        //
        pid += 1
        return dataEncrypt
    }
    //解密
    func decryptData(packets:[NSData])->[NSData]
    {
        var dataList=[NSData]()
        for p in packets
        {
			let data=decryptData(p:p)
            if(data.length>0)
            {   dataList.append(data)   }
        }
        return dataList
    }
    func decryptData(p:NSData)->NSData
    {
        let dataDecrypt=crypto.decryptData(p.subdata(with: NSMakeRange(1, p.length-1)))
		let dataForce:NSData = dataDecrypt! as NSData
        if((dataDecrypt?.count)!<5)
        {   return NSData()    }
        if(UnsafePointer<UInt8>(dataForce.bytes.assumingMemoryBound(to: UInt8.self)+4).pointee == 0xFA)
        {   return dataForce.subdata(with: NSMakeRange(5,dataForce.length-5)) as NSData   }
        else if(UnsafePointer<UInt8>(dataForce.bytes.assumingMemoryBound(to: UInt8.self)+4).pointee == 0x66)
        {   return lzo!.decompressNSData(dataForce.subdata(with: NSMakeRange(5,dataForce.length-5)))! as NSData  }
        //
        return NSData()
    }
    //写入
    func write(packets:[NSData])
    {
        for p in packets
        {
			let data=decryptData(p:p)
            if(data.length==0)
            {   continue   }
            //
            outPacketList.append(data)
        }
    }
    //读取
    func read()->[NSData]
    {
        let r=outPacketList
        outPacketList.removeAll()
        return r
    }
}
