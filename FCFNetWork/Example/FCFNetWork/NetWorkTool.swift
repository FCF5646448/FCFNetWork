//
//  NetWorkTool.swift
//  FCFNetWork_Example
//
//  Created by 冯才凡 on 2020/11/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FCFNetWork

class NetWorkTool : NSObject {
    
}

// 测试提供UA
extension NetWorkTool : NetWorkHandleProtocol {
    func getNetWorkHeaderUA() -> [String:String] {
        return ["project":"Mojito"]
    }
}
