# FCFNetWork

[![CI Status](https://img.shields.io/travis/FCF5646448/FCFNetWork.svg?style=flat)](https://travis-ci.org/FCF5646448/FCFNetWork)
[![Version](https://img.shields.io/cocoapods/v/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)
[![License](https://img.shields.io/cocoapods/l/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)
[![Platform](https://img.shields.io/cocoapods/p/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)

## 项目架构

最好的Alamofire的封装库就是Moya了。但是因为Moya太高度集成了，协议内容没法修改，不是非常契合我的需求。所以就有了这个库。

* 库中的kernellib是核心模块。是参照Moya进行的封装，使用协议定义一次接口请求。

  主要实现了拦截器、UA、Signature等，部分需要只预留了对外接口。(ps：还有很多待优化的模块)

除了kernellib，就是根据自身项目对核心模块的偏业务的封装。
* 数据解析 BaseResponse.swift

  库使用HandyJson进行数据解析。定义了一个BaseResponse来表示返回的response数据，使用泛型传入model，然后在接口返回的过程中进行了json——model的转换。
  其次因为我的接口返回格式固定类似以下格式，所以只返回了res的数据，Model的数据也只对应res内的数据：
```
{
    code: xx
    msg: xxx
    res: {}
}

{
    code: xx
    msg: xxx
    res: [{}]
}
```
* 入口NetManager.swift

  这个类定义了一个统一的请求接口函数。这也是为什么要封装Alamofire的原因，就是为了统一入口。其次定义了一个偏业务层的协议：TargetIncrease。它主要是协助实现请求下一页等函数。
```
	public protocol TargetIncrease {
    	var page: Int { get set }                       // 页码
    	var pageSize: Int { get set }                   // 每页个数
    	var fullParams: [String : Any]? { get set }     // 请求参数
    	func reload()                                   // 重新请求
    	func loadNextPage()                             // 请求下一页
	}
```
* 其他NetWorkHandle.swift。这个类只是作为辅助来用，比如网络状态监听等。

## Example

##### 所有的mode都必须继承自HandyJSON

```
struct RootMyCourseModel : HandyJSON {
    var rows : [CourseModel] = []
    var count : Int = 0
}

class CourseModel: HandyJSON {
    required init() { }
    var id : Int = 0
    var largePicture : String?
    var studentInfo : CourseStudentInfo?
    var title : String?
}

class CourseStudentInfo : HandyJSON {
    required init() { }
    var courseId : Int? //课程ID
    var isStudent : Int?
    var role : String? //角色
}
```

##### 接口实现API协议，每个接口都看做是一个协议，类似HTTP协议的一次请求。

```
// 每个模块可以单独订制一个枚举
enum BTLearnApi {
    case mineCourse //每个接口是一个枚举 case
}

// 实现配置信息，具体可配置信息参考 ApiRequestBaseObjProtocol
extension BTLearnApi  : ApiRequestBaseObjProtocol {
    
    var baseURL: URL {
         return URL(string: "https://api.btclass.net")!
    }
    
    public var method: Net.Method {
        return .get
    }
    
    var path: String {
        switch self {
        case  .mineCourse:
            return "/mojave/user/courses"
        }
    }
}
```

##### 请求进行请求

```
var coursesApi: NetManager<RootMyCourseModel>?

var param = [String:Any]()
param["needCount"] = 1
param["expireType"] = "expired"
self.coursesApi = NetManager<RootMyCourseModel>()
/**
 * API: 第一次创建 默认加载第0页
 * param： 参数
 * 20：每一页数据
 * slient：是否显示loading，👺TODO👺👺👺
 */
self.coursesApi?.request(BTLearnApi.mineCourse, param, 20, slient: false, success: { (response) in
    print("当前页：\(self.coursesApi?.page ?? 0)")
    if let obj = response?.resObj {
        print("数量：\(obj.rows.count)")
    }
}, error: { (error) in
    print(error)
}, failure: { (error) in
    print("网络异常")
})

//API: 重新加载第0页
self.coursesApi?.reload()
//API:  加载下1页
self.coursesApi?.loadNextPage()
```

#####  其他


* 可以实现NetWorkHandleProtocol协议设置UA和signature
```

NetWorkHandle.shareInstance.delegate = self
extension XXXX: NetWorkHandleProtocol {
     // 设置UA
    func getNetWorkHeaderUA() -> [String:String] {
        return ["project":"FCFNetWork"]
    }
    
    //
    func signatureDic(_ param:[String:Any]?) -> [String: Any] {
        // 这里可以对param进行处理，比如添加时间戳
       
        return param!
    }
}
```

* 可以实现NetInterceptor协议来拦截将要发送的请求和请求回调的数据

```
NetWorkHandle.shareInstance.adapter = self
// 拦截发送和接收
extension XXXX: NetInterceptor {
    func willSend(request: URLRequest) {
        print("🥳🚨🥳🚨🥳🚨\(request.httpMethod ?? ""): \(request.url?.absoluteString ?? "") 将要起飞了✈️✈️✈️✈️✈️")
    }
    
    func didReceive(statusCode: Int, request: URLRequest, response: HTTPURLResponse, json: [String: Any]) {
        print("🥳🚨🥳🚨🥳🚨 code:\(statusCode): \n \(request.httpMethod ?? ""): \(request.url?.absoluteString ?? "") \n responseJson: \(json)")
    }
}
```



## Requirements

## Installation 👺TODO👺👺👺

FCFNetWork is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FCFNetWork'
```

## Author

FCF5646448, 2998000457@qq.com

## License

FCFNetWork is available under the MIT license. See the LICENSE file for more info.

