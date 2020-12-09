//
//  BaseResponse.swift
//  Alamofire
//
//  Created by 冯才凡 on 2020/11/25.
//

import Foundation
import HandyJSON

//最外层基础数据
struct BaseObj : HandyJSON {
    
}

//对response进行处理
public class BaseResponse {
    public let json: [String : Any]
    public let responseStr : String?
    
    //页数
    var page:Int {
        guard let temp = json["page"] as? Int else {
            return 0
        }
        return temp
    }
    
    //每一页数据
    var pagesize:Int {
        guard let temp = json["pagesize"] as? Int else {
            return 0
        }
        return temp
    }
    
    //返回的code 200 才是正解
    var code:Int {
        guard let temp = json["code"] as? Int else {
            return -1
        }
        return temp
    }
    //如果数据错误，会返回msg或tips 优先级是 tip > msg
    var msgTip:String {
        if let tip = json["tip"] as? String , tip.count>0 {
            return tip
        }else if let msg = json["msg"] as? String {
            return msg
        }
        return ""
    }
    
    // 真正有用的model数据 它可能是数组也可能是字典
    public var jsonData:Any? {
        guard let temp = json["res"] else { //res
            return nil
        }
        return temp
    }
    
    init?(data: Any, responseStr:String? = nil) {
        self.responseStr = responseStr
        guard let temp = data as? [String : Any] else {
            return nil
        }
        self.json = temp
    }
    
    func json2Data(_ objc:Any) -> Data? {
        /**
         先判断是否可以转换
         */
        if !JSONSerialization.isValidJSONObject(objc) {
            return Data.init()
        }
        /**
         开始转换
         JSONSerialization.WritingOptions.prettyPrinted 是输出JSON时的格式更容易查看。
         */
        return try! JSONSerialization.data(withJSONObject: objc, options: .prettyPrinted)
    }
    
    func json2String(_ objc:Any) -> String? {
        if let tempD = json2Data(objc) {
            return String(data: tempD, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    // 返回可以直接 T.deserialize 的字符串数据，且必须是成功后的数据
    public var resJsonDataString:String? {
        get{
            if code == 200,
                let tempJSONData = jsonData,
                let temp = json2String(tempJSONData) {
                return temp
            }
            return nil
        }
    }
    
}

/* 默认的model结果是：
 {
    code:xx;
    res:{} (或者 res:[]);
    msg:xx;
    tip:xx;
 }
 
 基本所有可用的model都是建立在res之内的。所以 resObj与resArr就分别对应res作为{}和[];
 * 如果有不符合上述结构，则取resData的数据，不过它肯定是个{}
 */
public class ModelResponse<T>: BaseResponse where T: HandyJSON {
    //字典
    public var resObj:T?
    //数组
    public var resArr:[T]?
    //原始数据 可能是一个502的网页
    public var resData:T?
    
    // 具体数据解析函数
    func setResObj() {
        if code == 200,
            let tempJSONData = jsonData,
            let temp = json2String(tempJSONData)  {
            self.resObj = T.deserialize(from: temp)
        }else{
            self.resObj = nil
        }
    }
    
    // 具体数据解析函数
    func setResArr() {
        if code == 200,
            let tempJSONData = jsonData,
            let temp = json2String(tempJSONData)  {
            
            self.resArr = [T].deserialize(from: temp) as? [T]
        }else{
            self.resArr = nil
        }
    }
    
    //原始数据模型 可能是一个502的网页
    func serResData() {
        if let temp = json2String(self.json) {
            self.resData = T.deserialize(from: temp)
        }else{
            self.resData = nil
        }
    }
    
}

