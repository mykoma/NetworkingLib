//
//  HttpNetworking+PUT.swift
//  Networking
//
//  Created by Apple on 2016/11/1.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

extension HttpNetworking {
    
    // MARK:- PUT
    func rac_signalPUT(transaction : HttpTransaction) -> RACSignal {
        
        return RACSignal.createSignal { (subscriber :RACSubscriber!) -> RACDisposable! in
            self.processRequest(transaction,
                subscriber: subscriber,
                sendingBlock: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.logTransactionSending(transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    requestBean.request = Alamofire.request(transaction.toURLRequest()).responseJSON { [weak self](resp) in
                            guard let strongSelf = self else {
                                return
                            }
                            if let error = resp.result.error {
                                strongSelf.logTransactionError(transaction,
                                    error: error,
                                    resp: resp.response)
                                if transaction.needLoadFromCacheIfFailed {
                                    strongSelf.loadCacheForTransaction(transaction, subscriber: subscriber)
                                } else {
                                    subscriber.sendError(error)
                                }
                            } else if let value = resp.result.value {
                                strongSelf.logTransactionResponse(transaction, responseString: value.description)
                                strongSelf.alreadyReceivedResponse(value,
                                    transaction: transaction,
                                    subscriber: subscriber)
                            }
                    }
                })
            return RACDisposable()
        }
    }
    
}
