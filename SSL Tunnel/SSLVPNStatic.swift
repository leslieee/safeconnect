//
//  StaticKey.swift
//  SSL VPN
//
//  Created by shijia on 15/10/12.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation

///////////////请求参数///////////////
let bytesPing:[UInt8]=[0x2a,0x18,0x7b,0xf3,0x64,0x1e,0xb4,0xcb,0x07,0xed,0x2d,0x0a,0x98,0x1f,0xc7,0x48]//"PING"
let bytesPushRequset:[UInt8]=[0x50,0x55,0x53,0x48,0x5F,0x52,0x45,0x51,0x55,0x45,0x53,0x54,0x00]//"PUSH_REQUEST"
let bytesExt:[UInt8]=[0x00,0x00,0x00,0x00,0x00]//"Ext"
let bytesCompress:[UInt8]=[0x66]
let bytesNocompress:[UInt8]=[0xFA]
let bytes00:[UInt8]=[0x00]
let bytes01:[UInt8]=[0x01]

//
let dataPing:NSData = NSData(bytes: bytesPing, length: bytesPing.count)//"PING"
let dataPushRequset:NSData = NSData(bytes: bytesPushRequset, length:bytesPushRequset.count)//"PUSH_REQUEST"
let dataExt:NSData = NSData(bytes: bytesExt, length: bytesExt.count)//"Ext"
let dataCompress:NSData = NSData(bytes: bytesCompress, length: bytesCompress.count)
let dataNocompress:NSData = NSData(bytes: bytesNocompress, length: bytesNocompress.count)
let data00:NSData = NSData(bytes: bytes00, length: bytes00.count)//"0"
let data01:NSData = NSData(bytes: bytes01, length: bytes01.count)//"1"


///////////////Opcode///////////////
enum SSLVPNOpcode
{
    case SoftReset,Control,Ack,DataV1,HardResetClient,HardResetServer,DataV2
    var opcode:UInt8
    {
        switch self
        {
            case .SoftReset:return 0x03
            case .Control:return 0x04
            case .Ack:return 0x05
            case .DataV1:return 0x06
            case .HardResetClient:return 0x07
            case .HardResetServer:return 0x08
            case .DataV2:return 0x09
        }
    }
}
///////////////状态机参数///////////////
enum SSLVPNState
{
    case Error,Undef,Prepare,Initial,PerStart,Start,SendKey,GotKey,Active,PushRequest,GotReply,NomalOpen
    var code:Int
    {
        switch self
        {
            case .Error:return -2
            case .Undef:return -1
            case .Prepare:return 0
            case .Initial:return 1
            case .PerStart:return 2
            case .Start:return 3
            case .SendKey:return 4
            case .GotKey:return 5
            case .Active:return 6
            case .PushRequest:return 7
            case .GotReply:return 8
            case .NomalOpen:return 9
        }
    }
}

































