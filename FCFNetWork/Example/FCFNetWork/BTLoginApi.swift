//
//  BTLoginApi.swift
//  FCFNetWork_Example
//
//  Created by 冯才凡 on 2020/11/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FCFNetWork

//登录模块
enum BTLoginApi {
    case mobileLogin                //账号登录
}

extension BTLoginApi : ApiRequestBaseObjProtocol {
    
    var baseURL: URL {
         return URL(string: "https://api.btclass.net")!
    }
    
    public var method: Net.Method {
        return .post
    }
    
    public var path: String {
        switch self {
        case .mobileLogin:
            return "/v1/user/mobile/login"
        }
    }
}


enum BTLearnApi {
    case mineCourse                //我的课程列表
}

extension BTLearnApi  : ApiRequestBaseObjProtocol {
    
    var baseURL: URL {
         return URL(string: "https://api.btclass.net")!
    }
    
    public var method: Net.Method {
        return .get
    }
    
    var path: String {
        switch self {
        case  .mineCourse:
            return "/mojave/user/courses"
        }
    }
}


enum DownloadApi {
    case pic
}

