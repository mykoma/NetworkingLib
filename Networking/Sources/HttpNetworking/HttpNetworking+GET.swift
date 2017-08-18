//
//  HttpNetworking+GET.swift
//  Networking
//
//  Created by Apple on 2016/11/1.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CocoaLumberjack

/**
 *
 * 实现Http Get 请求
 *
 */
extension HttpNetworking {
    
    /**
     Implement download file when use HTTP GET method
     */
    func sendingGetStream(transaction : HttpTransaction) -> Observable<Any> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: transaction,
                               observer: observer,
                               sendingBlock:
                {
                    strongSelf.logSending(transaction: transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    requestBean.request = Alamofire.request(transaction.toURLRequest())
                        .responseJSON { (resp) in
                            strongSelf.process(response: resp,
                                               transaction: transaction,
                                               observer: observer)
                    }
                    if let dataRequest = transaction.currentRequest?.request as? DataRequest {
                        dataRequest.stream(closure: { (data) in
                            let string = String(data: data, encoding: String.Encoding.utf8)
                            DDLogDebug(string!)
                            _ = transaction.onStream(data: data)
                        })
                    }
            })
            return Disposables.create()
        })
    }
    
}

