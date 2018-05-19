//
//  Extension.swift
//  Safe Connect
//
//  Created by 陈强 on 17/2/23.
//  Copyright © 2017年 shijia. All rights reserved.
//

import Foundation
//import UIKit
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment:self)
    }
}
