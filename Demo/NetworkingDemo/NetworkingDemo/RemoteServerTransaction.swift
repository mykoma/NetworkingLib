//
//  RemoteServerTransaction.swift
//  NetworkingDemo
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 Goluk. All rights reserved.
//

import UIKit
import Networking

class RemoteServerTransaction: HttpTransaction {
    
    override func baseServerUrl() -> String {
        return "https://test2bservice.goluk.cn"
    }
    
    override func requestHeaders() -> [String: String] {
        var superHeaders = super.requestHeaders()
        
        superHeaders["xieyi"] = "100"
        superHeaders["commostag"] = "ios"
        superHeaders["commuid"] = "5baac280ea834a509873d86de4495c0a"
        superHeaders["commwifi"] = "1"
//        superHeaders["commlon"] = String(BMLocationService.sharedInstance.getPosition().longitude)
//        superHeaders["commlat"] = String(BMLocationService.sharedInstance.getPosition().latitude)
        superHeaders["commmid"] = "123"
//        superHeaders["commlocale"] = NSLocale.currentLocale().localeIdentifier
        superHeaders["commappversion"] = "1.0.0"
//        superHeaders["commdevmodel"] = UIDevice.currentDevice().model
//        superHeaders["commsysversion"] = UIDevice.currentDevice().systemVersion
//        superHeaders["commipcversion"] = AppSettings.sharedInstance()?.recentDeviceSoftVersion
//        superHeaders["commhdtype"] = AppSettings.sharedInstance()?.recentDeviceType
//
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        let timestamp = dateFormatter.string(from: Date.init())
        superHeaders["commtimestamp"] = timestamp
        if let ticket = self.genTicket(timestamp: timestamp) {
            superHeaders["commticket"] = ticket
        }
        return superHeaders
    }
    
    private func genTicket(timestamp: String) -> String? {
        let uuid = "5baac280ea834a509873d86de4495c0a"
        guard let UUIDString = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        let key = "7f5699a9892d44fa8bbc928d84cd3ffa"
        let value = "u=\(uuid)&m=\(UUIDString)&t=\(timestamp)"
        let result = CocoaSecurity.hmacSha256(value, hmacKey: key)
        return result?.hex
    }
    
}
