//
//  HttpNetworking+DOWNLOAD.swift
//  Networking
//
//  Created by Apple on 2016/11/1.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveCocoa

extension HttpNetworking {
    
    // MARK: DOWNLOAD
    func rac_signalDownload(transaction: HttpTransaction) -> RACSignal {
        
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
            self.processRequest(transaction,
                subscriber: subscriber,
                sendingBlock: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    // 记录最原始的 rac_subscriber
                    transaction.rac_subscriber = subscriber
                    strongSelf.logTransactionSending(transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    
                    requestBean.request = Alamofire.download(transaction.toURLRequest(),
                        destination: { temporaryURL, response in
                            let downloadTransaction = transaction as? HttpTransactionDownloadProtocol
                            guard downloadTransaction != nil else {
                                assert(false)
                                return NSURL(fileURLWithPath: "temp")
                            }
                            return downloadTransaction!.outputFilePath()
                    }).progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                        guard requestBean.isCancelled == false else {
                            return
                        }
                        if let progress = transaction.progress {
                            progress(bytesRead, totalBytesRead, totalBytesExpectedToRead)
                        }
                    }).responseData(completionHandler: { (response: Response<NSData, NSError>) in
                        switch response.result {
                        case .Success:
                            break
                        case .Failure:
                            if requestBean.isCancelled == true {
                                transaction.resumeData = response.data
                            }
                            break
                        }
                    }).response(completionHandler: { (_: NSURLRequest?, resp: NSHTTPURLResponse?, _: NSData?, error: NSError?) in
                        guard requestBean.isCancelled == false else {
                            return
                        }
                        guard let strongSelf = self else {
                            return
                        }
                        if let error = error {
                            strongSelf.logTransactionError(transaction,
                                error: error,
                                resp: resp)
                            if transaction.needLoadFromCacheIfFailed {
                                strongSelf.loadCacheForTransaction(transaction, subscriber: subscriber)
                            } else {
                                subscriber.sendError(error)
                            }
                        } else {
                            strongSelf.logTransactionResponse(transaction, responseString: resp.debugDescription)
                            strongSelf.alreadyReceivedResponse([Keys.Response.Download.Key: Keys.Response.Download.Success],
                                transaction: transaction,
                                subscriber: subscriber)
                        }
                    })
                    
                })
            return RACDisposable()
        })
    }
    
    // MARK: DOWNLOAD RESUME
    func rac_signalDownloadResume(transaction: HttpTransaction) -> RACSignal {
        
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
            self.processRequest(transaction,
                subscriber: subscriber,
                sendingBlock: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard let resumeData = transaction.resumeData else {
                        return
                    }
                    strongSelf.logTransactionSending(transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    requestBean.request = Alamofire.download(resumeData: resumeData,
                        destination: { temporaryURL, response in
                            let downloadTransaction = transaction as? HttpTransactionDownloadProtocol
                            guard downloadTransaction != nil else {
                                assert(false)
                                return NSURL(fileURLWithPath: "temp")
                            }
                            return downloadTransaction!.outputFilePath()
                    }).progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                        guard requestBean.isCancelled == false else {
                            return
                        }
                        if let progress = transaction.progress {
                            progress(bytesRead, totalBytesRead, totalBytesExpectedToRead)
                        }
                    }).responseData(completionHandler: { (response: Response<NSData, NSError>) in
                        switch response.result {
                        case .Success:
                            break
                        case .Failure:
                            if requestBean.isCancelled == true {
                                transaction.resumeData = response.data
                            }
                            break
                        }
                    }).response(completionHandler: { (_: NSURLRequest?, resp: NSHTTPURLResponse?, _: NSData?, error: NSError?) in
                        guard requestBean.isCancelled == false else {
                            return
                        }
                        guard let strongSelf = self else {
                            return
                        }
                        if let error = error {
                            strongSelf.logTransactionError(transaction,
                                error: error,
                                resp: resp)
                            if transaction.needLoadFromCacheIfFailed {
                                strongSelf.loadCacheForTransaction(transaction, subscriber: subscriber)
                            } else {
                                subscriber.sendError(error)
                            }
                        } else {
                            strongSelf.logTransactionResponse(transaction, responseString: resp.debugDescription)
                            strongSelf.alreadyReceivedResponse([Keys.Response.Download.Key: Keys.Response.Download.Success],
                                transaction: transaction,
                                subscriber: subscriber)
                        }
                    })
                    
                })
            return RACDisposable()
        })
    }
}
