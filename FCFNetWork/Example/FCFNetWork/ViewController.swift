//
//  ViewController.swift
//  FCFNetWork
//
//  Created by FCF5646448 on 11/23/2020.
//  Copyright (c) 2020 FCF5646448. All rights reserved.
//

import UIKit
import FCFNetWork


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = ["获取用户数据","获取课程列表第一页","获取课程列表下一页"]
    
    var coursesApi: NetManager<RootMyCourseModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
    }

}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            getUser()
        }else if indexPath.row == 1 {
            getCourseList()
        }else if indexPath.row == 2 {
            if (self.coursesApi != nil) {
                self.coursesApi?.loadNextPage()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}

extension ViewController : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
}


extension ViewController {
    func getUser() {
        var param = [String:Any]()
               param["area"] = "86"
               param["mobile"] = "1804020498"
               param["password"] = "testtest"
        
        NetManager<User>().request(BTLoginApi.mobileLogin, param, success: { (response) in
            if let obj = response?.resObj {
                print(obj.nickname as Any)
            }
        }, error: { (error) in
            print(error)
        }) { (error) in
            print("网络异常")
        }
    }
    
    func getCourseList() {
        if (self.coursesApi != nil) {
            self.coursesApi?.reload()
        }else{
            var param = [String:Any]()
            param["needCount"] = 1
            param["expireType"] = "expired"
            
            self.coursesApi = NetManager<RootMyCourseModel>()
            self.coursesApi?.request(BTLearnApi.mineCourse, param, 20, slient: false, success: { (response) in
                print("当前页：\(self.coursesApi?.page ?? 0)")
                if let obj = response?.resObj {
                    
                    print("课程数量：\(obj.rows.count)")
                }
            }, error: { (error) in
                print(error)
            }, failure: { (error) in
                print("网络异常")
            })
        }
    }
}



