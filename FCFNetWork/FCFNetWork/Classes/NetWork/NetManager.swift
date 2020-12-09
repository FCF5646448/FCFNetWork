//
//  NetManager.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/25.
//

import Foundation
import HandyJSON

// 过渡一下
public protocol ApiRequestBaseObjProtocol : TargetType {
    
}

//通过扩展为协议实现默认的方法
public extension ApiRequestBaseObjProtocol {
    var headers: [String : String]? { NetWorkHandle.shareInstance.getRequestHeader() }
}

// 为BT APP 装门封装的协议
public protocol BTTargetIncrease {
    var page: Int { get set }                       // 页码
    var pageSize: Int { get set }                   // 每页个数
    var fullParams: [String : Any]? { get set }     // 请求参数
    func reload()                                   // 重新请求
    func loadNextPage()                             // 请求下一页
}


public class NetManager<T: HandyJSON> : NSObject, BTTargetIncrease {
    // 实现协议属性
    public var page: Int {
        get {
            return _page
        }
        set {
            _page = newValue
        }
    }
    public var pageSize: Int {
        get {
            return _pageSize
        }
        set {
            _pageSize = newValue
        }
    }
    public var fullParams: [String : Any]? {
        get {
            return _params
        }
        
        set {
            _params = newValue
        }
    }
    
    //response
    public var code: Int = 0
    
    private var _params: [String : Any]?
    private var _page: Int = 0
    private var _pageSize: Int = 0
    private var _request: Net.Request!
    private var _target: TargetType!
    private var _isloadNextPaging = false //正在请求下一页，用于在特殊情况下重置page
    
    private var _slient: Bool = true
    
    
    
    // 回调
    public var success: ((ModelResponse<T>?) -> Void)? = nil
    public var error: ((String)->Void)? = nil
    public var failure: ((Net.Error)->Void)? = nil
    
    
    /**
     请求参数
     param：可不传，只在分页情况下传参
     slient: 只是用于对一些与界面无关的请求是否显示toast
     success：服务器连接成功，且数据正确返回（同时会自动将数据转换成 JSON 对象，方便使用）
     error：服务器连接成功，但数据返回错误（同时会返回错误信息）
     failure ：服务器连接不上，网络异常等
     return: 返回一个cancelable 可用于取消
     */
    public func request<R:TargetType>(_ target: R,
                                      _ param: [String:Any]? = nil,
                                      _ pageSize: Int = 0,
                                      slient: Bool = true,
                                      success successCallback: ((ModelResponse<T>?) -> Void)? = nil,
                                      error errorCallback: ((String)->Void)? = nil,
                                      failure failureCallback: ((Net.Error)->Void)? = nil) {
        
        _target = target
       
        _pageSize = pageSize
        var tmpParam: [String:Any] = param ?? [:]
        if _pageSize > 0 {
            // page == 0
            _page = 0
            tmpParam["page"] =  _page
            tmpParam["limit"] = _pageSize
            
        }
        _params = tmpParam
        
        _slient = slient
        success = successCallback
        error = errorCallback
        failure = failureCallback
        _isloadNextPaging = false
        requestReal(success: successCallback, error: errorCallback, failure: failureCallback)
        
    }
    
    /* 重新请求当前接口
     */
    public func reload() {
        guard _target != nil else {
            return
        }
        var param:[String:Any] = _params ?? [:]
        if _pageSize > 0 {
            // page == 0
            _page = 0
            param["page"] =  _page
            param["limit"] = _pageSize
            
        }
        _params = param
        _isloadNextPaging = false
        requestReal(success: self.success, error: self.error, failure: self.failure)
    }
    
    /*
     请求下一页
     */
    public func loadNextPage() {
        guard _target != nil else {
            return
        }
        var param:[String:Any] = _params ?? [:]
        if let page = param["page"] as? Int {
            //page > 1
            _page = page + 1
            param["page"] =  _page
            
        }else if _pageSize > 0{
            //page == 1
            _page = 1
            param["page"] =  _page
            param["limit"] = _pageSize
            
        }
        _params = param
        _isloadNextPaging = true
        requestReal(success: self.success, error: self.error, failure: self.failure)
    }
    
    // 如果请求下一页没有成功返回数据，表明是最后一页了，所以需要将页码重置
    private func _resetPage() {
        guard _target != nil && _isloadNextPaging else {
            return
        }
        var param:[String:Any] = _params ?? [:]
        if let page = param["page"] as? Int, page > 0 {
            _page = page - 1
            param["page"] =  _page
        }
    }
    
    /*
     取消正在进行的请求
     */
    public func cancel() {
        _request.cancel()
    }
    
    /*
     真正进行网络请求的地方
     其实，无论是
     */
    private func requestReal(success successCallback: ((ModelResponse<T>?) -> Void)? = nil,
                             error errorCallback: ((String)->Void)? = nil,
                             failure failureCallback: ((Net.Error)->Void)? = nil) {
        
        _request = Net.request(_target,
                               (NetWorkHandle.shareInstance.delegate?.signatureDic?(_params) ?? _params),
                               NetWorkHandle.shareInstance.adapter)
        _request.response(type: T.self) {[weak self] response in
            switch response.result {
            case let .success(wrapper):
                self?.code = wrapper.code
                if wrapper.code != 200 {
                    let msg = wrapper.msgTip
                    errorCallback?(msg )
                    
                    if wrapper.code == 410 {
                        //重新登录
                        NotificationCenter.default.post(name: NSNotification.Name("NetCode_410"), object: nil)
                    }else if wrapper.code == 411 {
                        //强制登出
                        NotificationCenter.default.post(name: NSNotification.Name("NetCode_411"), object: nil)
                    }
                    return
                }
                
                // 订制 res 里的数据模型
                wrapper.setResObj()
                wrapper.setResArr()
                wrapper.serResData()
                
                if let pg = self?._page,  pg > 0 && (self?._isloadNextPaging ?? false)  {
                    // 如果是正在请求下一页
                    if (wrapper.resArr?.count ?? 0) < 1 {
                        // 说明最新页码，没有多余数据
                        self?._resetPage()
                    }
                }
                
                successCallback?(wrapper)
            case let .failure(error):
                switch error {
                case .unParse(_):
                    errorCallback?(error.message)
                default:
                    // .server,.unknown:
                    failureCallback?(error)
                }
            }
        }
        
    }
    
    deinit {
        print("NetManager deinit")
    }
    
}
