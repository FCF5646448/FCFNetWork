//
//  DownloadTargetType.swift
//  Mojave
//
//  Created by 冯才凡 on 2020/12/3.
//  Copyright © 2020 卓明. All rights reserved.
//

import Foundation

public protocol NetDownloadConvertible: NetRequestConvertible {
    var downloadle: Net.Downloadable { get }
    var fileDirectory: URL { get }
}

public protocol DownloadTargetType: NetDownloadConvertible {
    var baseURL: URL { get }                            // 域名
    var path: String { get }                            // url
    var headers: [String: String]? { get }              // 头部特殊设置
    
    var timeoutInterval: TimeInterval { get }           // 请求超时时间 default: 30
    var signature: Net.SignEncryption { get }       //网络请求签名方式  default:.none
}

extension DownloadTargetType {
    public func asNetRequest(_ param: [String:Any]?) throws -> URLRequest {
        var originRequest = try URLRequest(url: url, method: .get, headers: headers)
        originRequest.timeoutInterval = timeoutInterval
        let newRequest = try encoding.encode(originRequest, with: param)
        
        switch signature {
        case .AES:
            
            return newRequest
        case .none:
            return newRequest
        }
    }
    
    public var contentType: Net.ContentType {
        return .url
    }
    
    public var encoding: Net.encoding {
        return Net.encoding.urlencoding(.query)
    }
    
    public var signature: Net.SignEncryption {
        .none
    }
    
    public var timeoutInterval: TimeInterval {
        30
    }
    
    public var url: URL {
        return URL(string: baseURL.absoluteString + self.path)!
    }
    
    public var headers: [String : String]? { nil }
    
    public var fileDirectory: URL {
        let doc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .localDomainMask, true)
        guard let path = doc.last else {
            fatalError("[NET]: 文件目录异常")
        }
        return URL(fileURLWithPath: path)
    }
    
}


extension Net {
    public enum Downloadable {
        
        /// Download should be started from the `URLRequest` produced by the associated `URLRequestConvertible` value.
        case request(NetRequestConvertible)
        
        /// Download should be started from the associated resume `Data` value.
        case resumeData(Data)
    }
}
