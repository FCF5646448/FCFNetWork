//
//  BaseUrlHost.swift
//  FCFNetWork_Example
//
//  Created by 冯才凡 on 2020/11/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FCFNetWork
import HandyJSON

// 基础服务器域名 每个都有默认值，默认是正式环境
public class BaseUrlHost: NSObject, HandyJSON {
    required override public init() { super.init() }
    public var tiku:String = "https://api.btclass.cn"
    public var im:String = "https://api.btclass.cn/im"
    public var prod_base:String = "https://api.btclass.cn"
    public var test_base:String = "https://api.btclass.net"
    public var tikuUrl:String = "https://api.btclass.cn/tiku"
    public var h5Url:String = "https://m.btclass.cn"
    public var parrotUrl:String = "https://api.btclass.cn/im"
    public var tokenUrlPattern:String = ""
}

enum MojitoBaseApi {
    case baseHost
}

extension MojitoBaseApi : ApiRequestBaseObjProtocol {
    
    var baseURL: URL {
        let urlStr = true ? "https://api.btclass.net" : "https://api.btclass.cn"
         return URL(string: urlStr)!
    }
    
    var path: String {
        return "/v1/sierra/baseUrl"
    }
    
    var method: Net.Method {
        return .get
    }
}

