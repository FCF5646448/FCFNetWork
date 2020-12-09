# FCFNetWork

[![CI Status](https://img.shields.io/travis/FCF5646448/FCFNetWork.svg?style=flat)](https://travis-ci.org/FCF5646448/FCFNetWork)
[![Version](https://img.shields.io/cocoapods/v/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)
[![License](https://img.shields.io/cocoapods/l/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)
[![Platform](https://img.shields.io/cocoapods/p/FCFNetWork.svg?style=flat)](https://cocoapods.org/pods/FCFNetWork)

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

接口实现API协议

```
enum BTLearnApi {
    case mineCourse
}

// 实现配置信息
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

请求进行请求

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

### 其他

可以实现NetWorkHandleProtocol协议设置UA和signature

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

可以实现NetInterceptor协议来拦截将要发送的请求和请求回调的数据

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
