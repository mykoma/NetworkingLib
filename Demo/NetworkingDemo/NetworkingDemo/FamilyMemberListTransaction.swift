//
//  LoginTransaction.swift
//  NetworkingDemo
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 Goluk. All rights reserved.
//

import UIKit
import Networking

class FamilyMemberListTransaction: RemoteServerTransaction {
    override func subUri() -> String {
        return "/carbox/shares"
    }
    
    override func httpType() -> HttpMethodType {
        return .GET
    }
}
