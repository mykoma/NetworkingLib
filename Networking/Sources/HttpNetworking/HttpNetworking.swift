//
//  HttpNetworking.swift
//  SwiftNetwork
//
//  Created by apple on 16/7/10.
//  Copyright © 2016年 qz. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CocoaLumberjack

public struct Keys {
    
    // 响应
    public struct Response {
        // 下载
        public struct Download {
            // Key
            public static let Key                   = "com.goluk.download.key"
            // 成功
            public static let Success               = "com.goluk.download.success"
            // 失败
            public static let Failed                = "com.goluk.download.failed"
        }
    }
    
}

public protocol HttpNetworkingProtocol: NSObjectProtocol {
    /**
     *  返回是否可以发送请求
     */
    func couldSendRequest(transaction :HttpTransaction) -> Bool
    
    /**
     *  请求被禁止发送
     */
    func requestNotAllowToSend(transaction :HttpTransaction)
    
    /**
     *  将要发送请求
     */
    func willSendRequest(transaction :HttpTransaction)
    
    /**
     *  处理服务器发过来的请求.
     */
    func didReceiveResponse(response :AnyObject)
    
    /**
     *  拦截服务器发过来的请求.
     */
    func interceptResponse(response :AnyObject)
}

public class HttpNetworking: NSObject {
    
    var networkingManager: Alamofire.SessionManager?
    
    public var delegate : HttpNetworkingProtocol?
    
    public static let sharedInstance = HttpNetworking()
    
    private override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        self.networkingManager = Alamofire.SessionManager.init(configuration: config)
    }
    
}

// MARK:- private
extension HttpNetworking {
    
    /**
     Handle the transaction.
     
     @Discussion
     1. Load cache
     2. Get the "send out permission" from delegate
     3. Tell the delegate this transaction has forbidden to send out
     4. Tell the delegate this transaction will be send out
     */
    func process(transaction: HttpTransaction!, observer: AnyObserver<Any>, sendingBlock block: (()->Void)!) {
        var couldSend = true

        let needLoadFromCache = transaction.needLoadFromCache // Check if need to load from cache
        guard needLoadFromCache == false else {
            self.loadCache(transaction: transaction, observer: observer)
            return
        }

        if let couldSendRequest = self.delegate?.couldSendRequest { // Ask delegate if could send this transaction
            couldSend = couldSendRequest(transaction)
        }
        guard couldSend == true else { // If can't send this transaction
            if let requestNotAllowToSend = self.delegate?.requestNotAllowToSend {
                requestNotAllowToSend(transaction)
            }
            // TODO Error
            return
        }

        if let willSendRequest = self.delegate?.willSendRequest { // Tell delegate will send this transaction
            willSendRequest(transaction)
        }

        block() // Callback, do thing which sending.
    }

    /**
     Load cache response for the transaction.
     */
    func loadCache(transaction : HttpTransaction, observer :AnyObserver<Any>) {
        if let cacheObject = transaction.cacheObject() { // Cache Response
            guard let cachedResponse = cacheObject.loadResponse() else {
                let error = NSError.init(domain: "com.goluk.error", code: -1, userInfo: nil)
                observer.onError(error)
                return
            }
            self.received(response: cachedResponse,
                          transaction: transaction,
                          observer: observer)
        }
    }

    /**
     Received response for the transaction.
     
     @Discussion
     1. Intercept this response before handle it.
     2. Tell the delegate received this response.
     3. Let this transaction handle its response.
     4. Pop out the handled result.
     5. Cache this response if need.
     */
    func received(response: AnyObject, transaction: HttpTransaction, observer: AnyObserver<Any>) {
        if let interceptResponse = self.delegate?.interceptResponse {
            interceptResponse(response)
        }

        if let didReceiveResponse = self.delegate?.didReceiveResponse {
            didReceiveResponse(response)
        }

        DispatchQueue.global().async {
            let responseObject = transaction.onResponse(response: response)
            DispatchQueue.main.async {
                let first = responseObject != nil ? responseObject : NSNull()
                // 1. responseObject which handled by Transaction
                // 2. the original response sent by server
                // 3. the transaction
                let tuple = (first!, response, transaction)
                observer.onNext(tuple)
                observer.onCompleted()
            }
            
            repeat { // To cache response
                guard transaction.needCacheReponse == true else {
                    break
                }
                
                transaction.cacheObject()?.cacheResponse(response: response) 
                
            } while false
        }
    }
    
    func process(response: DataResponse<Any>, transaction: HttpTransaction, observer: AnyObserver<Any>) {
        if let error = response.result.error {
            self.logError(transaction: transaction,
                                error: error,
                                response: response.response)
            if transaction.needLoadFromCacheIfFailed {
                self.loadCache(transaction: transaction,
                                     observer: observer)
            } else {
                observer.onError(error)
            }
        } else if let value = response.result.value {
            self.logReceived(transaction: transaction,
                             responseString: (value as AnyObject).description)
            self.received(response: value as AnyObject,
                          transaction: transaction,
                          observer: observer)
        }
    }
}

// MARK:- Log
extension HttpNetworking {
    
    func logSending(transaction: HttpTransaction) {
        DDLogDebug("====================>\n\(transaction.httpType().rawValue) Request:\n"
            + transaction.url().urlEncoding() + "\n" + transaction.toParameters().description + "\n")
    }
    
    func logReceived(transaction: HttpTransaction, responseString: String) {
        DDLogDebug("<====================\n\(transaction.httpType().rawValue) RESPONSE:\n"
            + responseString
            + "\nFOR URL: \n"
            + transaction.url().urlEncoding())
    }
    
    func logError(transaction: HttpTransaction, error: Error, response: HTTPURLResponse? = nil) {
        DDLogDebug("<====================\n\(transaction.httpType().rawValue) ERROR RESPONSE:\n"
            + "\nHeaders: \(String(describing: response?.allHeaderFields))\n"
            + error.localizedDescription
            + "\nFOR URL: \n"
            + transaction.url().urlEncoding())
    }
    
}

extension HttpNetworking {
    
    /**
     Send out the common transaction.
     */
    func sendOut(commonTransaction: HttpTransaction) -> Observable<Any> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: commonTransaction,
                               observer: observer,
                               sendingBlock:
                {
                    strongSelf.logSending(transaction: commonTransaction)
                    let requestBean = HttpTransaction.RequestBean()
                    commonTransaction.currentRequest = requestBean
                    requestBean.request = Alamofire.request(commonTransaction.toURLRequest()).responseJSON
                        { [weak self](resp) in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.process(response: resp,
                                               transaction: commonTransaction,
                                               observer: observer)
                    }
            })
            return Disposables.create()
        })
    }
}

extension String {
    
    func urlEncoding() -> String {
        if let newUrl = self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "`#%^{}\"[]|\\<> ").inverted) {
            return newUrl
        }
        return self
    }
    
}
