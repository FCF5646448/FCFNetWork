//
//  Net.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/24.
//

import Foundation
import Alamofire
import HandyJSON


/*
 网络请求核心类，主要用于对接Alamofire
 */
public struct Net {
    
     private static let session: SessionManager = {
           let session = SessionManager()
           session.delegate.sessionDidReceiveChallenge = { session, challenge in
               return (.performDefaultHandling, URLCredential(trust: challenge.protectionSpace.serverTrust!))
           }
           return session
       }()
       
    
    /*
     直接传入target，param 直接发起请求
     返回一个 Request
     */
    public static func request(_ target: TargetType, _ param: [String: Any]? = nil, _ adapter: NetInterceptor?) -> Request {
        do {
            //设置适配器
            if adapter != nil {
                session.adapter = Interceptor(adapter:adapter)
            }else{
                session.adapter = nil
            }
            return Request(request: session.request(try target.asNetRequest(param)))
        } catch  {
            fatalError(error.localizedDescription)
        }
    }
    
    /*
     下载
     */
    public static func download(_ target: NetDownloadConvertible, _ param: [String: Any]? = nil, _ adapter: NetInterceptor?) -> Download {
        let downloadRequest: URLRequest
        do {
            downloadRequest = try target.asNetRequest(param)
        } catch  {
            fatalError(error.localizedDescription)
        }
        
        if adapter != nil {
            session.adapter = Interceptor(adapter:adapter)
        }else{
            session.adapter = nil
        }
        
        
        let destination: (URL, HTTPURLResponse) -> (URL, Alamofire.DownloadRequest.DownloadOptions) = { (url, response) in
            // 表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (target.fileDirectory, [.removePreviousFile, .createIntermediateDirectories])
        }
        

        return Download(download: session.download(downloadRequest, to: destination))
    }
    
    
    /*
     取消所有网络请求
     */
    public static func cancelAll() {
        session.session.getAllTasks { (tasks) in
            tasks.forEach {
                $0.cancel()
            }
        }
    }
    
}



/*
 订制Request
 */
extension Net {
    public struct Request {

        fileprivate let request: DataRequest
        
        
        internal init(request: DataRequest) {
            self.request = request
        }
        
        // 取消当前网络请求
        public func cancel() {
            request.cancel()
        }
        
        //
        @discardableResult
        public func response<T: HandyJSON>(type: T.Type, use decoder: JSONDecoder? = nil, completion: @escaping (Response<ModelResponse<T>, Net.Error>) ->Void) -> Self {
            request.responseData { (response) in
                // 初始化一个response
                let dataResponse: Net.Response<Data?, Swift.Error>
                switch response.result {
                case let .success(data):
                    dataResponse = .init(request: response.request, response: response.response, data: data, result: .success(data))
                case let .failure(error):
                    dataResponse = .init(request: response.request, response: response.response, data: response.data, result: .failure(error))
                }
                
                // 这里还可以插入网络拦截相关数据
                self.adapt(dataResponse, using: (Net.session.adapter as? Net.Interceptor)) { (response) in
                    switch response.result {
                    case let .success(data):
                        guard let data = data, let dataStr = String(data: data, encoding: .utf8) else {
                            completion(.init(request: response.request, response: response.response, data: nil, result: .failure(Net.Error.server)))
                            return
                        }
                        
                        do {
                            let resData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let object = ModelResponse<T>(data: resData, responseStr: dataStr) {
                                completion(.init(request: response.request, response: response.response, data: data, result: .success(object)))
                            }else{
                                let decodeError: Net.Error = .unParse(nil)
                                completion(.init(request: response.request, response: response.response, data: data, result: .failure(decodeError)))
                            }
                            
                        } catch  {
                            let decodeError: Net.Error = .unParse(error)
                            completion(.init(request: response.request, response: response.response, data: data, result: .failure(decodeError)))
                        }
                    case let .failure(error):
                        let failError: Net.Error = error as? Net.Error ?? .unknown
                        completion(.init(request: response.request, response: response.response, data: response.data, result: .failure(failError)))
                    }
                    
                }
            }
            
            return self
        }
        
        private func adapt(_ response: Net.Response<Data?, Swift.Error>,
                           using adapter: Interceptor?, completion: @escaping (Net.Response<Data?, Swift.Error>) -> Void) {
            
            defer {
                completion(response)
            }
            
            guard adapter != nil else {  return }
            
            if let data = response.data, let resData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json: [String: Any] = resData as? [String: Any] {
                adapter?.adapter?.didReceive?(statusCode: response.statusCode ?? 0, request: response.request!, response: response.response!, json: json)
            }else{
                adapter?.adapter?.didReceive?(statusCode: response.statusCode ?? 0, request: response.request, response: response.response, json: nil)
            }
        }
        
    }
}


extension Net {
    // 
    public struct Download {
        
        fileprivate let download: DownloadRequest
        
        
        internal init(download: DownloadRequest) {
            self.download = download
        }
        
        @discardableResult
        public func downloadProgress( progress: @escaping (Progress) -> Void) -> Self {
            download.downloadProgress(closure: progress)
            return self
        }
        
        @discardableResult
        public func response( completion: @escaping (Response<Data, Net.Error>) ->Void) -> Self {
            download.responseData { (response) in
                let dataResponse: Net.Response<Data?, Swift.Error>
                switch response.result {
                    case let .success(data):
                        dataResponse = .init(request: response.request, response: response.response, data: data, result: .success(data))
                    case let .failure(error):
                        dataResponse = .init(request: response.request, response: response.response, data: response.resumeData, result: .failure(error))
                }
                
                self.adapt(dataResponse, using: (Net.session.adapter as? Net.Interceptor)) { (response) in
                    switch response.result {
                    case let .success(data):
                        guard let data = data, let _ = String(data: data, encoding: .utf8) else {
                            completion(.init(request: response.request, response: response.response, data: nil, result: .failure(Net.Error.server)))
                            return
                        }
                        completion(.init(request: response.request, response: response.response, data: data, result: .success(data)))
                        
                    case let .failure(error):
                        let failError: Net.Error = error as? Net.Error ?? .unknown
                        completion(.init(request: response.request, response: response.response, data: response.data, result: .failure(failError)))
                    }
                }
                
            }
            return self
        }
            
        
        private func adapt(_ response: Net.Response<Data?, Swift.Error>,
                           using adapter: Interceptor?, completion: @escaping (Net.Response<Data?, Swift.Error>) -> Void) {
            
            defer {
                completion(response)
            }
            
            guard adapter != nil else {  return }
            
            if let data = response.data, let resData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json: [String: Any] = resData as? [String: Any] {
                adapter?.adapter?.didReceive?(statusCode: response.statusCode ?? 0, request: response.request!, response: response.response!, json: json)
            }else{
                adapter?.adapter?.didReceive?(statusCode: response.statusCode ?? 0, request: response.request, response: response.response, json: nil)
            }
        }

        
        
        
        // 取消当前网络请求
        public func cancel() {
            download.cancel()
        }
    }
}


/*
 定义一个Response
 由Success和Failt泛型组成
 */
extension Net {
    public struct Response<Success, Failure: Swift.Error> {
        public let request: URLRequest?             // 请求request
        public let response: HTTPURLResponse?       // 响应response
        public let statusCode: Int?                 // 响应 状态码
        public let data: Data?                      // 响应 data
        public let result: Swift.Result<Success, Failure> // 响应结果
        
        public var success: Success? {
            guard case let .success(value) = result else {
                return nil
            }
            return value
        }
        
        public var failure: Failure? {
            guard case let .failure(error) = result else {
                return nil
            }
            return error
        }
        
        public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, result: Swift.Result<Success, Failure>) {
            self.request = request
            self.response = response
            self.statusCode = response?.statusCode
            self.data = data
            self.result = result
        }
        
        
    }
}

extension Swift.Result {
    @discardableResult
    public func successHandle(_ handler: @escaping (Success) -> Void) -> Self {
        if case .success(let value) = self {
            handler(value)
        }
        return self
    }
    
    @discardableResult
    public func failureHandle(_ handler: @escaping (Failure) -> Void) -> Self {
        if case .failure(let error) = self {
            handler(error)
        }
        return self
    }
}

extension Net {
    public enum Error: Swift.Error {
        case unknown
        case server
        case unParse(Swift.Error?)
        case info(String)
        
        var message: String {
            switch self {
            case .unknown:
                return "未知错误"
            case .server:
                return "服务器发生异常，请稍后再试。"
            case .unParse:
                return "无法解析为指定格式"
            case let .info(msg):
                return msg
            }
        }
    }
}
