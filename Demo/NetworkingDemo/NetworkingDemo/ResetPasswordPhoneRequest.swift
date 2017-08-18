//
//  ResetPasswordPhoneRequest.swift
//  CarAssist
//
//  Created by Apple on 2017/6/1.
//  Copyright © 2017年 cn.carassist. All rights reserved.
//

import Foundation
import Networking

class ResetPasswordPhoneRequest: RemoteServerTransaction {
    
    var dialingcode : String? = "86"
    var phone : String? = "13018238370"
    var vcode : String? = "1693"
    var pwd : String? = "b6197fe0d62a4e463edd2925382d4d268c4fce0859378682608efa4fda326f26-"
    
    override func subUri() -> String {
        return "/user/password/phone"
    }
    
    override func httpType() -> HttpMethodType {
        return .PUT
    }
    
}
