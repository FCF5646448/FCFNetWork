//
//  Modes.swift
//  FCFNetWork_Example
//
//  Created by 冯才凡 on 2020/11/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON

struct User: HandyJSON {
    //
    var userId : Int?
    var id: Int?{
        didSet{
            self.userId = id
        }
    }
    
    var studentid : Int?
    var nickname: String?
    var largeAvatar: String?
}



struct RootMyCourseModel : HandyJSON {
    var rows : [CourseModel] = []
    var count : Int = 0
}

// 课程详情Model
class CourseModel: HandyJSON {

    required init() { }
    
    var id : Int = 0
    var largePicture : String?
    var studentInfo : CourseStudentInfo?
    var title : String?
}


// MARK:- BTCourseStudentInfo
class CourseStudentInfo : HandyJSON {
    required init() { }
    var courseId : Int? //课程ID
    var isStudent : Int?
    var role : String? //角色
}
