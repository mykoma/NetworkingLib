////
////  HttpNetworking+DOWNLOAD.swift
////  Networking
////
////  Created by Apple on 2016/11/1.
////  Copyright © 2016年 goluk. All rights reserved.
////
//
import Foundation
import Alamofire
import RxSwift

extension HttpNetworking {
    
    // MARK: DOWNLOAD
    func sendingDownload(transaction: HttpTransaction) -> Observable<Any> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: transaction,
                               observer: observer,
                               sendingBlock:
                {
                    // 记录最原始的 observer
                    transaction.rxObserver = observer
                    strongSelf.logSending(transaction: transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    
                    let downloadRequest = Alamofire.download(transaction.toURLRequest(),
                                                             to:
                        { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                            guard let downloadTransaction = transaction as? HttpTransactionDownloadProtocol else {
                                assert(false)
                                return (URL.init(fileURLWithPath: "temp"), [.removePreviousFile])
                            }
                            return (downloadTransaction.outputFilePath(), [.removePreviousFile])
                    })
                    requestBean.request = strongSelf.download(request: downloadRequest,
                                                              transaction: transaction,
                                                              observer: observer)
                })
            return Disposables.create()
        })
    }
    
    // MARK: DOWNLOAD RESUME
    func sendingDownloadResume(transaction: HttpTransaction) -> Observable<Any> {
        
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: transaction,
                               observer: observer,
                               sendingBlock:
                {
                    guard let resumeData = transaction.resumeData else {
                        return
                    }
                    strongSelf.logSending(transaction: transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    let downloadRequest = Alamofire.download(resumingWith: resumeData,
                                                             to:
                        { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                            guard let downloadTransaction = transaction as? HttpTransactionDownloadProtocol else {
                                assert(false)
                                return (URL.init(fileURLWithPath: "temp"), [.removePreviousFile])
                            }
                            return (downloadTransaction.outputFilePath(), [.removePreviousFile])
                    })
                    
                    requestBean.request = strongSelf.download(request: downloadRequest,
                                                              transaction: transaction,
                                                              observer: observer)
            })
            return Disposables.create()
        })
    }
    
    private func download(request: DownloadRequest, transaction: HttpTransaction, observer: AnyObserver<Any>) -> Request {
        return request.downloadProgress(closure: { (p) in
            guard transaction.currentRequest?.isCancelled == false else {
                return
            }
            transaction.onProgress?(p)
        }).responseData(completionHandler: { (response) in
            switch response.result {
            case .success:
                break
            case .failure:
                if transaction.currentRequest?.isCancelled == true {
                    transaction.resumeData = response.resumeData
                }
                break
            }
        }).response(completionHandler: { [weak self](response) in
            guard let strongSelf = self else {
                return
            }
            guard transaction.currentRequest?.isCancelled == false else {
                return
            }
            if let error = response.error {
                strongSelf.logError(transaction: transaction,
                                    error: error,
                                    response: response.response)
                if transaction.needLoadFromCacheIfFailed {
                    strongSelf.loadCache(transaction: transaction,
                                         observer: observer)
                    
                } else {
                    observer.onError(error)
                }
            } else {
                strongSelf.logReceived(transaction: transaction,
                                       responseString: (response.response as AnyObject).description)
                strongSelf.received(response: response.response as AnyObject,
                                    transaction: transaction,
                                    observer: observer)
            }
        })
    }
}

