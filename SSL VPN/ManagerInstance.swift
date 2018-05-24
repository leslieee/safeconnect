//
//  ManagerInstance.swift
//  Safe Connect
//
//  Created by 陈强 on 16/12/28.
//  Copyright © 2016年 shijia. All rights reserved.
//
import Foundation
import NetworkExtension
final class ManagerInstance: NSObject {
    var manager:NEVPNManager?
	var login:NSInteger?
    var IPAddress:String?
	var userName:String?
    var timeOutTime:NSInteger?
    //单例
	static let shared = ManagerInstance()  
	private override init() {} 

}
