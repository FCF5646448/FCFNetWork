//
//  Net+Interceptor.swift
//  FCFNetWork
//
//  Created by 冯才凡 on 2020/11/25.
//

import Foundation
import Alamofire

// 拦截器，用于在网络willSend、didReceived的时候拦截网络请求。接口日志考虑在这里拦截打印
extension Net {
    internal class Interceptor: Alamofire.RequestAdapter {
        
        weak var adapter: NetInterceptor?
        
        init(adapter: NetInterceptor?) {
            self.adapter = adapter
        }
        
        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            
            adapter?.willSend?(request: urlRequest)
            
            return urlRequest
        }
        
    }
}
