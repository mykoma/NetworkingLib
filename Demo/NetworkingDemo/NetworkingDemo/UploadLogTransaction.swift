//
//  UploadLogsTransaction.swift
//  CrazyPanda
//
//  Created by Apple on 2016/12/5.
//  Copyright © 2016年 Goluk. All rights reserved.
//

import Foundation
import Networking

class UploadLogTransaction: RemoteServerTransaction {

    var filePath: URL?
    
    override func baseServerUrl() -> String {
        return "https://testservice.crazypandacam.com"
    }
    
    override func subUri() -> String {
        return "/system/log"
    }
    
    override func httpType() -> HttpMethodType {
        return .POST_FORM
    }
    
    override func httpData() -> Data? {
        guard let filePath = self.filePath else {
            return nil
        }
        
        guard let data = try? Data.init(contentsOf: filePath) else {
            return nil
        }
        return data
    }
    
    override func httpMultipartFormName() -> String {
        return "file"
    }
    
    override func httpMultipartFormFileName() -> String {
        return "filename"
    }
    
    override func httpMultipartFormMimeType() -> String {
        return "application/text"
    }
    
    override func excludeParameters() -> [String] {
        var superList = super.excludeParameters()
        superList.append("filePath")
        return superList
    }
    
}
