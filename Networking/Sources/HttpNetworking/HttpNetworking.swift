//
//  HttpNetworking.swift
//  SwiftNetwork
//
//  Created by apple on 16/7/10.
//  Copyright © 2016年 qz. All rights reserved.
//

import Foundation
import ReactiveCocoa
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
    
    var networkingManager: Alamofire.Manager?
    
    public var delegate : HttpNetworkingProtocol?
    
    public static let sharedInstance = HttpNetworking()
    
    private override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 60
        self.networkingManager = Alamofire.Manager(configuration: config)
    }
    
}

// MARK:- private
extension HttpNetworking {
    
    func processRequest(transaction: HttpTransaction!, subscriber: RACSubscriber!, sendingBlock block: (()->Void)!) {
        var couldSend = true
        
        // Check if need to load from cache
        let needLoadFromCache = transaction.needLoadFromCache
        
        guard needLoadFromCache == false else {
            self.loadCacheForTransaction(transaction, subscriber: subscriber)
            return
        }
        
        // Ask delegate if could send this transaction
        if let couldSendRequest = self.delegate?.couldSendRequest {
            couldSend = couldSendRequest(transaction)
        }
        
        guard couldSend == true else {
            // If can't send this transaction
            if let requestNotAllowToSend = self.delegate?.requestNotAllowToSend {
                requestNotAllowToSend(transaction)
            }
            // TODO Error
            return
        }
        
        // Tell delegate will send this transaction
        if let willSendRequest = self.delegate?.willSendRequest {
            willSendRequest(transaction)
        }
        
        // Callback, do thing which sending.
        block()
    }
    
    func loadCacheForTransaction(transaction : HttpTransaction, subscriber :RACSubscriber!) {
        // Cache Response
        if let cacheObject = transaction.cacheObject() {
            
            guard let cachedResponse = cacheObject.loadResponse() else {
                subscriber.sendError(nil)
                return
            }
            self.alreadyReceivedResponse(cachedResponse,
                                         transaction: transaction,
                                         subscriber: subscriber)
        }
    }
    
    func alreadyReceivedResponse(response : AnyObject, transaction : HttpTransaction, subscriber :RACSubscriber!) {
        if let interceptResponse = self.delegate?.interceptResponse {
            interceptResponse(response)
        }
        
        if let didReceiveResponse = self.delegate?.didReceiveResponse {
            didReceiveResponse(response)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            let responseObject = transaction.onResponse(response)
            dispatch_async(dispatch_get_main_queue(), {
                let first = responseObject != nil ? responseObject : NSNull()
                // 1. responseObject which handled by Transaction
                // 2. the original response sent by server
                // 3. the transaction
                let tuple = RACTuple(objectsFromArray:[first!, response, transaction])
                subscriber.sendNext(tuple)
                subscriber.sendCompleted()
            })
            // Cache Response
            repeat {
                guard transaction.needCacheReponse == true else {
                    break
                }
                
                transaction.cacheObject()?.cacheResponse(response)
                
            } while false
        })
    }
    
}

// MARK:- Log
extension HttpNetworking {
    
    func logTransactionSending(transaction: HttpTransaction) {
        DDLogDebug("====================>\n\(transaction.httpType().rawValue) Request:\n"
            + transaction.url().urlEncoding())
    }
    
    func logTransactionResponse(transaction: HttpTransaction, responseString: String) {
        DDLogDebug("<====================\n\(transaction.httpType().rawValue) RESPONSE:\n"
            + responseString
            + "\nFOR URL: \n"
            + transaction.url().urlEncoding())
    }
    
    func logTransactionError(transaction: HttpTransaction, error: NSError, resp: NSHTTPURLResponse? = nil) {
        DDLogDebug("<====================\n\(transaction.httpType().rawValue) ERROR RESPONSE:\n"
            + "\nHeaders: \(resp?.allHeaderFields)\n"
            + error.localizedDescription
            + "\nFOR URL: \n"
            + transaction.url().urlEncoding())
    }
    
}

extension String {
    
    func urlEncoding() -> String {
        
        if let newUrl = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.init(charactersInString: "`#%^{}\"[]|\\<> ").invertedSet) {
            return newUrl
        }
        return self
        
    }
    
}
