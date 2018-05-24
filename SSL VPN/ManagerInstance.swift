//
//  ManagerInstance.swift
//  Safe Connect
//
//  Created by 陈强 on 16/12/28.
//  Copyright © 2016年 shijia. All rights reserved.
//
import Foundation
import NetworkExtension
class ManagerInstance: NSObject {
    var manager:NEVPNManager?
      var login:NSInteger?
    var IPAddress:String?
     var userName:String?
    var timeOutTime:NSInteger?
    //单例
    class func shareSingle()->ManagerInstance{
        struct Singleton{
            static var onceToken : dispatch_once_t = 0
            static var single:ManagerInstance?
        }
        dispatch_once(&Singleton.onceToken,{
            Singleton.single=ManagerInstance()
            
            
            }
        )
        return Singleton.single!
    }

}
