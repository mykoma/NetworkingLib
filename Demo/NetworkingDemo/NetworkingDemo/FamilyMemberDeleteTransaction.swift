//
//  FamilyMemberDeleteTransaction.swift
//  CarAssist
//
//  Created by Apple on 2017/6/26.
//  Copyright © 2017年 cn.carassist. All rights reserved.
//

import Foundation
import Networking

class FamilyMemberDeleteTransaction: RemoteServerTransaction {

    var otheruid: String?

    override func subUri() -> String {
        return "/carbox/share"
    }
    
    override func httpType() -> HttpMethodType {
        return .DELETE
    }
    
}
