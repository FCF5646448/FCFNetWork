//
//  Protocol.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/24.
//

import Foundation

/*
 定义一个协议接口，实现一个生成URLRequest的方法。
 注：定义协议时，不允许有默认参数
 */
public protocol NetRequestConvertible {
    func asNetRequest(_ param: [String:Any]?) throws -> URLRequest
}


/*
 定义一个协议接口，提供将参数和原始的URLRequest实现生产一个新的URLRequest的方法
 */
public protocol NetParameterEncoding {
    func encode(_ request: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}



// 暂时只拦截了返回后的结果m，用于打印日志。后续可以扩展，拦截将要willSend的方法，方便整合 loading的组件。
@objc public protocol NetInterceptor {
    // 拦截将要发送的url，后续可以扩展检测URL是否有效的校验规则
    @objc optional func willSend(request: URLRequest)
    
    /*
     拦截获取到的接口返回
    */
    @objc optional func didReceive(statusCode: Int, request: URLRequest?, response: HTTPURLResponse?, json: [String: Any]?)
}


