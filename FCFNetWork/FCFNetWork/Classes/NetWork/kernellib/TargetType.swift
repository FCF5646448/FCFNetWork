//
//  TargetType.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/24.
//

import Foundation


/*
 仿写Moya的形式：通过协议TargetType来表示一个API请求。
 所有的属性设置成不可变状态，便于测试。
 */
public protocol TargetType: NetRequestConvertible {
    var baseURL: URL { get }                            // 域名
    var path: String { get }                            // url
    var headers: [String: String]? { get }              // 头部特殊设置
    var method: Net.Method { get }                      // 请求类型
    var contentType: Net.ContentType { get }            // 编码类型
    var encoding: Net.encoding { get }                  // 参数编码方式
    
    var timeoutInterval: TimeInterval { get }           // 请求超时时间 default: 30
    var cachePolicy: URLRequest.CachePolicy { get }     // 缓存策略
    var signature: Net.SignEncryption { get }       //网络请求签名方式  default:.none
}


/*
 扩展提供默认实现
 */
extension TargetType {
    public var contentType: Net.ContentType {
        switch self.method {
        case .post,.put,.delete,.patch:
            return .json
        default:
            return .url
        }
    }
    
    public var encoding: Net.encoding {
        switch self.contentType {
        case .url:
            return Net.encoding.urlencoding(.default) //目前默认是Default，如果是upload则使用
        case .json:
            return Net.encoding.jsonencoding
        }
    }
    
    public var cachePolicy: URLRequest.CachePolicy {
        URLSessionConfiguration.default.requestCachePolicy
    }
    
    public var signature: Net.SignEncryption {
        .none
    }
    
   public var timeoutInterval: TimeInterval {
        30
    }
    
    // 全路径
    public var url: URL {
        return URL(string: baseURL.absoluteString + self.path)!
    }
    
    public var headers: [String : String]? {nil}
    
}

/*
 实现NetRequestConvertible协议，将TargetType转成一个URLRequest
 */
extension TargetType {
    public func asNetRequest(_ param: [String:Any]?) throws -> URLRequest {
        let originRequest = try __makeBaseRequest()
        
        let newRequest = try encoding.encode(originRequest, with: param)
        // 在这里对URLRequest进行加密，Todo
        switch signature {
        case .AES:
            
            return newRequest
        case .none:
            return newRequest
        }
    }
}

extension TargetType {
    fileprivate func __makeBaseRequest() throws -> URLRequest {
        var request = try URLRequest(url: url,
                                     method: method.mapAla(),
                                     headers: __makeHeader())
        
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy
        return request
    }
    
    fileprivate func __makeHeader() -> [String: String] {
        let defaultHeaders = [
        "Accept": "*/*",
        "Content-Type": self.contentType.type,
        "x-phone-type": "iOS",
        ].compactMapValues{$0}
        let headers = defaultHeaders.merging(self.headers ?? [:]) { (_, value) -> String in
            return value
        }
        return headers
    }
}
