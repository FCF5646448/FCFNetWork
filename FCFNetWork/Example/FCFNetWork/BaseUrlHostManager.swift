//
//  BaseUrlHostManager.swift
//  FCFNetWork_Example
//
//  Created by 冯才凡 on 2020/11/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FCFNetWork

class BaseUrlHostManager: NSObject  {
    static let shareInstance = BaseUrlHostManager()
    private override init() {
        super.init()
    }
    
    
    public var baseHost: BaseUrlHost {
        get{
            // 每一次先获取缓存的数据,没有缓存则取默认数据，同时进行刷新。刷新完之后，通知已更新接口
            let versionStr:String = "" //MMKVManager.share.mkDefault.string(forKey: "BTBaseURL") ?? ""

            if let obj:BaseUrlHost = BaseUrlHost.deserialize(from: versionStr) {
                return obj
            }else{
                //没有缓存 则先返回默认接口，然后同时请求接口。
                BaseUrlHostManager.shareInstance.refreshBaseUrlHost()
                return BaseUrlHost()
            }
        }
    }
    
    
    //更新服务器
    public func refreshBaseUrlHost(_ complete:((_ result:Bool)->Void)?=nil) {
        NetManager<BaseUrlHost>().request(MojitoBaseApi.baseHost, success: { (response) in
            //请求回来直接缓存到数据库
            if let str = response?.resJsonDataString {
                print(str)
//                MMKVManager.share.mkDefault.set(str, forKey: "BTBaseURL")
                complete?(true)
            }else{
                complete?(false)
            }
        }, error: { (error) in
            print("\(error)")
            complete?(false)
        }, failure: { (failError) in
            print("未连接服务器")
            complete?(false)
        })
    }
    
    
    
    
}


