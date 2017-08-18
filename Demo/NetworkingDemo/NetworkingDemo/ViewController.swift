//
//  ViewController.swift
//  NetworkingDemo
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 Goluk. All rights reserved.
//

import UIKit
import Networking
import RxSwift
import CocoaLumberjack

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in 0 ... 200000 {
//            DDLogVerbose("12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890")
//        }

//        let t = FamilyMemberListTransaction()
        
//        let t = LoginTransaction()
//        t.dialingcode = "86"
//        t.phone = "13018238370"
//        t.pwd = "b6197fe0d62a4e463edd2925382d4d268c4fce0859378682608efa4fda326f26"
//
//        let filePaths = FileLogger.sharedInstance?.logFileManager.sortedLogFilePaths
//        for filePath in filePaths! {
//            guard let path = filePath as? String else {
//                break
//            }
//            let t = UploadLogTransaction()
//            t.filePath = URL.init(fileURLWithPath: filePath)
//            t.onProgress = { (p) in
//                NSLog("\(p)")
//            }
//            t.send().subscribe(onNext: { (obj) in
//                DDLogVerbose("123")
//            }, onError: { (error) in
//                NSLog("456")
//            }, onCompleted: {
//                NSLog("789")
//            }) {
//                NSLog("aaa")
//            }
//            break
//        }
        
//        let t = OAuthTransaction()
        
//        let t = ResetPasswordPhoneRequest()
        
        let t = FamilyMemberDeleteTransaction()
        t.otheruid = "3f93615eff3343e39a855c2470b98592"
        
        t.onProgress = { (p) in
            NSLog("\(p)")
        }
        t.send().subscribe(onNext: { (obj) in
            DDLogVerbose("123")
        }, onError: { (error) in
            NSLog("456")
        }, onCompleted: {
            NSLog("789")
        }) {
            NSLog("aaa")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

