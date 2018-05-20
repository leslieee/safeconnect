//
//  OpenVPNString.swift
//  SSL VPN
//
//  Created by shijia on 15/11/18.
//  Copyright © 2015年 shijia. All rights reserved.
//

import Foundation

func stringToNsdata(str:String)->NSData
{
    let data:NSMutableData=NSMutableData()
    let dataStr:NSData=str.data(using: String.Encoding.ascii)! as NSData
    var bytes0:UInt8=0x00
    var len:UInt16=(UInt16(dataStr.length+1)).bigEndian
    data.append(&len, length: 2)
    data.append(dataStr as Data)
    data.append(&bytes0, length: 1)
    return data
}
