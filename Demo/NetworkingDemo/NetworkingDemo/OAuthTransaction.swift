//
//  OAuthTransaction.swift
//  NetworkingDemo
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 Goluk. All rights reserved.
//

import UIKit
import Networking

class OAuthTransaction: RemoteServerTransaction {
    
    // value of AuthType.rawValue
    var platform: String? = "weixin"
    var openid: String? = "oMLAX1csGr1Zka88rTlVRVkQFRVQ"
    var name: String? = "成都老刘"
    var gender: Int? = 1
    var avatar: String? = "http://wx.qlogo.cn/mmopen/INk4JvWfe8U2ibibdeYkxah8PZd6PKrqJJKT3KvSZ9p1sBVIeW6NQDpSTgzkNCw6lgyvTB4hCHH42eiadWnF43HOFzmFvUEmQIF/0"
    
    override func subUri() -> String {
        return "/user/authlogin"
    }
    
    override func httpType() -> HttpMethodType {
        return .POST_BODY
    }
    
    override func httpData() -> Data? {
        var dict: [String: AnyObject] = [:]
        if let openid = openid {
            dict["openid"] = openid as AnyObject
        }
        if let name = name {
            dict["name"] = name as AnyObject
        }
        if let avatar = avatar {
            dict["avatar"] = avatar as AnyObject
        }
        if let gender = gender {
            dict["sex"] = gender  as AnyObject
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        return jsonData
    }
    
    override func excludeParameters() -> [String] {
        var superList = super.excludeParameters()
        superList.append("openid")
        superList.append("name")
        superList.append("gender")
        superList.append("avatar")
        return superList
    }
}

