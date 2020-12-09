//
//  NetWorkHandle.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/26.
//

import Foundation


@objc public protocol NetWorkHandleProtocol {
    // 暴露一个接口，用于传入UA。
    @objc optional func getNetWorkHeaderUA() -> [String:String]
    // 🤪业务层暴露对参数进行加密的接口。因为手法不佳，所以不值得写到Net+Signature里面
    @objc optional func signatureDic(_ param:[String:Any]?) -> [String: Any]
}

extension NetWorkHandleProtocol {
    func signatureDic(_ param:[String:Any]?) -> [String: Any] {
        return param ?? [:]
    }
}


// 用于协助网络请求相关工作, 偏业务层
@objc public class NetWorkHandle : NSObject {
    @objc public static let shareInstance = NetWorkHandle()
    private override init() {
        super.init()
    }
    
    @objc public weak var delegate: NetWorkHandleProtocol?
    
    public weak var adapter: NetInterceptor?
    
    // 网络
    @objc public var netStatus: NetStatus = .unknow
    @objc public func reachNet() {
        Net.Reachability.reachNet()
    }
    
    //
    func getRequestHeader() -> [String: String]? {
        var originUA = [String:String]()
        var netString = "Unknown"
        switch netStatus {
        case .notReachable:
            netString = "NotReachable"
        case .unknow:
            netString = "Unknown"
        case .WiFi:
            netString = "WiFi"
        case .wwan:
            netString = "WWAN"
        }
        originUA["nettype"] = netString
        
        if let otherSet = self.delegate?.getNetWorkHeaderUA?() {
            originUA = originUA.merging(otherSet){ (current, _) in current }
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: originUA, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return ["app_info":jsonString]
        }
        
        return nil
    }
    
    @objc public func isReachable() -> Bool {
        return Net.Reachability.isReachable()
    }
    
    @objc public func cancelAllRequest() {
        Net.cancelAll()
    }
    
}
