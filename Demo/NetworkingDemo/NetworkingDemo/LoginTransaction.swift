//
//  LoginTransaction.swift
//  NetworkingDemo
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 Goluk. All rights reserved.
//

import UIKit
import Networking

class LoginTransaction: RemoteServerTransaction {
    
    var dialingcode : String = "123"
    var phone : String = "111"
    var pwd : String = "122"
    var xieyi: String = "100"
        
    override func subUri() -> String {
        return "/user/login/phone"
    }
    
    override func httpType() -> HttpMethodType {
        return .POST
    }

}
