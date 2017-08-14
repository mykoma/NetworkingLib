//
//  HttpNetworking+POST.swift
//  Networking
//
//  Created by Apple on 2016/11/1.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

extension HttpNetworking {
    
    // MARK: POST
    func rac_signalPOST(transaction: HttpTransaction) -> RACSignal {
        
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
    
    // MARK: POST WITH BODY
    func rac_signalPOSTBody(transaction: HttpTransaction) -> RACSignal {
        
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
                    requestBean.request = Alamofire.request(transaction.toURLRequest())
                        .progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                            if let progress = transaction.progress {
                                progress(bytesRead, totalBytesRead, totalBytesExpectedToRead)
                            }
                        })
                        .responseJSON { [weak self](resp) in
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
    
    // MARK: POST WITH FORM
    func rac_signalPOSTForm(transaction: HttpTransaction) -> RACSignal {
        
        return RACSignal.createSignal { (subscriber :RACSubscriber!) -> RACDisposable! in
            self.processRequest(transaction,
                subscriber: subscriber,
                sendingBlock: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.logTransactionSending(transaction)
                    Alamofire.upload(transaction.toURLRequest(),
                        multipartFormData: { (form: MultipartFormData) in
                            if let data = transaction.httpData() {
                                form.appendBodyPart(data: data,
                                    name: transaction.httpMultipartFormName(),
                                    fileName: transaction.httpMultipartFormFileName(),
                                    mimeType: transaction.httpMultipartFormMimeType())
                            }
                        }, encodingCompletion: { (encodingResult: Manager.MultipartFormDataEncodingResult) in
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                                    if let progress = transaction.progress {
                                        progress(bytesRead, totalBytesRead, totalBytesExpectedToRead)
                                    }
                                }).responseJSON { [weak self](resp) in
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
                            case .Failure(let encodingError):
                                print(encodingError)
                                subscriber.sendError(nil)
                            }
                    })
                }
            )
            return RACDisposable()
        }
    }
    
}
