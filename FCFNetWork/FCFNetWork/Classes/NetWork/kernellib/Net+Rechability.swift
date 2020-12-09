//
//  Net+Rechability.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/26.
//

import Foundation
import Alamofire

//网络
@objc public enum NetStatus : NSInteger {
    case unknow = -1 //未知
    case notReachable = 0 //无连接
    case wwan = 1 //2，3，4G网络
    case WiFi = 2 //wifi
}

extension Net {
    public struct Reachability {
        
        public static var netStatus: NetStatus = .unknow
        
        // 监控网络变化 同时设置一下初始 UA
        public static func reachNet() {
            let net = NetworkReachabilityManager()
            net?.listener = { (status) in
                let oldStatus = self.netStatus
                if net?.isReachable ?? false {
                    var netString = "Unknown"
                    switch status {
                    case .reachable(.ethernetOrWiFi):
                        netStatus = .WiFi
                        netString = "WiFi"
                        break
                    case .reachable(.wwan):
                        netStatus = .wwan
                        netString = "WWAN"
                        break
                    case .notReachable:
                        netStatus = .notReachable
                        netString = "NotReachable"
                        break
                    case .unknown :
                        netStatus = .unknow
                        break
                    }
                    if oldStatus != netStatus {
                        NotificationCenter.default.post(name: NSNotification.Name.init("NetStatuChange"), object: nil)
                    }
                    
                }else{
                    netStatus = .notReachable
                    NotificationCenter.default.post(name: NSNotification.Name.init("NetStatuChange"), object: nil)
                }
                
            }
            net?.startListening()
        }

        public static func isReachable() -> Bool {
            return NetworkReachabilityManager()?.isReachable ?? false
        }
    }
}
