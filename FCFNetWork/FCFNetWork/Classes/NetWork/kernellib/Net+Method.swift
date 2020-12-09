//
//  Net+Method.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/24.
//

import Foundation
import Alamofire

/*
 网络请求类型，将其定位Net的属性，更便于使用。
 */
extension Net {
    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
        case patch  = "PATCH"
        
        // 映射成Alamofire的请求方法。
        public func mapAla() -> Alamofire.HTTPMethod {
            switch self {
            case .get:
                return .get
            case .post:
                return .post
            case .put:
                return .put
            case .delete:
                return .delete
            case .patch:
                return .patch
            }
        }
    }
}
