//
//  Net+Encoding.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/24.
//

import Foundation
import Alamofire

/*
 编码类型：
 Content-Type就是告诉服务器，我目前的参数使用什么编码方式，这样服务器就可以使用对应的方式对客户端发送过来的数据进行解析。（正常来说请求头的content-Type表示客户端发送过来的数据的编码方式，响应头的content-Type表示服务器返回的内容的编码格式）
 在设置 Content-Type的同时，参数也得进行对应的encoding，实现真正的编码。
 Content-Type 说明：https://zhuanlan.zhihu.com/p/69261642
 
 *  application/json 和 application/x-www-form-urlencoded的区别:
    * 2.1 application/json;;charset=utf-8
        作用： 告诉服务器请求的主题内容是json格式的字符串，服务器端会对json字符串进行解析
        好处： 前端人员不需要关心数据结构的复杂度，只要是标准的json格式就能提交成功。
    * 2.2  application/x-www-form-urlencoded;charset=utf-8
    作用：默认方式在请求发送过程中会对数据进行序列化处理，以键值对形式？key1=value1&key2=value2的方式发送到服务器
        好处： 所有浏览器都支持
 */
extension Net {
    
    public enum ContentType: String {
        case url                    // 消息主体是序列化后的 JSON 字符串
        case json                   // 数据被编码为名称/值对。这是标准的编码格式
//        case formdata               // 需要在表单中进行文件上传时，
//        case text                   // 数据以纯文本形式(text/json/xml/html)进行编码，其中不含任何控件或格式字符
        
        public var type: String {
            switch self {
            case .url:
                return "application/x-www-form-urlencoded"
            case .json:
                return "application/json"
//            case .formdata:
//                return "multipart/form-data"
//            case .text:
//                return "text/plain"
            }
        }
    }
    
}


/*
 参数编码方式。对应content-Type类型。
 根据content-Type类型对当前参数进行编码，以便服务器能够正常解析。
 */
extension Net {
    public enum encoding: NetParameterEncoding {
        case jsonencoding
        case urlencoding(URLEncoding)
        
        public enum URLEncoding {
            case `default`
            case query
        }
        
        public func encode(_ request: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
            switch self {
            case .jsonencoding:
                return try Alamofire.JSONEncoding.default.encode(request, with: parameters)
            case .urlencoding(.default):
                return try Alamofire.URLEncoding.default.encode(request, with: parameters)
            case .urlencoding(.query):
                return try Alamofire.URLEncoding.queryString.encode(request, with: parameters)
            }
        }
        
    }
}

extension URLRequest:  URLRequestConvertible {
    public func asNetRequest() throws -> URLRequest {
        return self
    }
}

