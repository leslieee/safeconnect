//
//  OpenVPNStruct.swift
//  SSL VPN
//
//  Created by shijia on 15/11/2.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation


///////////////数据包///////////////
struct PacketControl
{
    var opcode:UInt8
    var id:UInt32
    var tid:UInt32
    var timeout:TimeInterval
    var data:NSData
    var isHold:Bool
    //
    init(ID:uint,TID:uint)
    {
        opcode=SSLVPNOpcode.Ack.opcode
        id=ID
        tid=TID
        data=NSData.init()
        isHold=true
        timeout = 0
    }
    init(Opcode:UInt8,ID:UInt32,Data:NSData)
    {
        opcode=Opcode
        id=ID
        tid=0
        data=Data
        isHold=true
        timeout = 0
    }
    init(Opcode:UInt8,ID:uint,TID:UInt32,Data:NSData)
    {
        opcode=Opcode
        id=ID
        tid=TID
        data=Data
        isHold=true
        timeout = 0
    }
}



