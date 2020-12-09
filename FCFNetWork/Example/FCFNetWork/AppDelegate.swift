//
//  AppDelegate.swift
//  FCFNetWork
//
//  Created by FCF5646448 on 11/23/2020.
//  Copyright (c) 2020 FCF5646448. All rights reserved.
//

import UIKit
import FCFNetWork


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NetWorkHandle.shareInstance.delegate = self
        NetWorkHandle.shareInstance.adapter = self
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


extension AppDelegate: NetWorkHandleProtocol {
    func getNetWorkHeaderUA() -> [String:String] {
        return ["project":"FCFNetWork"]
    }
    
    func signatureDic(_ param:[String:Any]?) -> [String: Any] {
        // 这里可以对param进行处理，比如添加时间戳
       
        return param!
    }
}

// 拦截发送和接收
extension AppDelegate: NetInterceptor {
    func willSend(request: URLRequest) {
        print("✈️✈️✈️\(request.httpMethod ?? ""): \(request.url?.absoluteString ?? "") 将要起飞了✈️✈️✈️\n")
    }
    
    func didReceive(statusCode: Int, request: URLRequest?, response: HTTPURLResponse?, json: [String: Any]?) {
        var str = "API \(request?.httpMethod ?? "") :\(request?.url?.absoluteString ?? "")"
        
        if json?["code"] != nil {
            str += "【Code:\(json!["code"]!)】\n"
        }else{
           str += "【Code: 请求失败】🥳🚨🥳🚨🥳🚨 \n"
        }
        
        var headerStr = ""
        if let headerData = try? JSONSerialization.data(withJSONObject: request?.allHTTPHeaderFields as Any, options: JSONSerialization.WritingOptions.prettyPrinted) {
            headerStr = String(data: headerData, encoding: String.Encoding.utf8) ?? ""
            
            str += "header:\n\(headerStr)\n "
        }
        
        if let data = request?.httpBody, let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)  as Any, let json = jsonData as? Dictionary<String, Any> {
            str += "params: \(json)\n "
        }
        
        if json != nil {
            str += "responseJson:{\n \( json! ) \n} \n"
        }
        print(str)
    }
}
