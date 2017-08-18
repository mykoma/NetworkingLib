//
//  HttpTransaction.swift
//  SwiftNetwork
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 qz. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CocoaLumberjack

public enum HttpMethodType: String {
    case DELETE         = "DELETE"          // DELETE
    case POST           = "POST"            // POST
    case POST_FORM      = "POST_FORM"       // POST WITH FORM
    case POST_BODY      = "POST_BODY"       // POST WITH BODY
    case GET            = "GET"             // GET
    case GET_STREAM     = "GET_STREAM"      // GET WITH STREAM
    case PUT            = "PUT"             // PUT
    case DOWNLOAD       = "DOWNLOAD"        // DOWNLOAD
}

// MARK:- HttpTransactionAuthorizationProtocol
public protocol HttpTransactionAuthorizationProtocol: NSObjectProtocol {
    /**
     *  If Need Authorization
     */
    func needAuthorizationBeforeSend() -> Bool
    /**
     *  If show Auth view when check authorization failed
     */
    func needShowAuthWhenCheckAuthorizationFailed() -> Bool
}

// MARK:- HttpTransactionDownloadProtocol
public protocol HttpTransactionDownloadProtocol: NSObjectProtocol {
    
    func outputFilePath() -> URL
    
}

// MARK:- HttpTransaction
open class HttpTransaction: NSObject {
    
    class RequestBean: NSObject {
        weak var request: Request?
        var isCancelled: Bool = false
    }
    var currentRequest: RequestBean?
    var rxObserver: AnyObserver<Any>?
    
    deinit {
        DDLogInfo("deinit in \(self)")
    }
    
// MARK: Progress
    open var onProgress: ((_ p: Progress) -> Void)?
    
// MARK: Cache
    open var needLoadFromCache:Bool = false
    open var needLoadFromCacheIfFailed:Bool = false
    open var needCacheReponse:Bool = false
    
    open func cacheObject() -> HttpResponseCache? {
        return nil
    }
    
    open func toURLRequest() -> URLRequest {
        let url = URL.init(string: self.url().urlEncoding())
        let mURLRequest = NSMutableURLRequest.init(url: url!,
                                                   cachePolicy: .useProtocolCachePolicy,
                                                   timeoutInterval: self.timeoutInterval())
        switch self.httpType() {
        case .DELETE:
            mURLRequest.httpMethod = Alamofire.HTTPMethod.delete.rawValue
            break
        case .GET, .GET_STREAM, .DOWNLOAD:
            mURLRequest.httpMethod = Alamofire.HTTPMethod.get.rawValue
            break
        case .PUT:
            mURLRequest.httpMethod = Alamofire.HTTPMethod.put.rawValue
            break
        case .POST, .POST_BODY, .POST_FORM:
            mURLRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
            break
        }
        mURLRequest.allHTTPHeaderFields = self.requestHeaders()
        if self.httpType() == .POST_BODY {
            mURLRequest.httpBody = self.httpData()
        }
        return mURLRequest as URLRequest
    }
    
// MARK:- Override
    open func url() -> String {
        var uri = self.baseServerUrl() + self.subUri()
        if uri.contains("?") {
            uri = uri + "&"
        } else {
            uri = uri + "?"
        }
        uri = uri + self.toSuburiFromParameters()
        return uri
    }

    open func baseServerUrl() -> String {
        DDLogError("Must override >>baseServerUrl<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    open func subUri() -> String {
        DDLogError("Must override >>subUri<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    open func httpType() -> HttpMethodType {
        DDLogError("Must override >>httpType<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return HttpMethodType.POST
    }
    
    open func timeoutInterval() -> TimeInterval {
        return 60
    }
    
    open func toDictionary() -> [String: String] {
        return [:]
    }
    
    open func requestHeaders() -> [String: String] {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
    
    open func httpMultipartFormName() -> String {
        return ""
    }
    
    open func httpMultipartFormFileName() -> String {
        return ""
    }
    
    open func httpMultipartFormMimeType() -> String {
        return ""
    }
    
    open func httpData() -> Data? {
        return nil
    }
    
    open func excludeParameters() -> [String] {
        return ["needLoadFromCacheIfFailed",
                "needCacheReponse",
                "needLoadFromCache",
                "onProgress",
                "currentRequest",
                "rxObserver"]
    }
    
    open func send() -> Observable<Any> {
        var signal: Observable<Any>
        
        let networking = HttpNetworking.sharedInstance
        switch self.httpType() {
        case .GET, .POST, .PUT, .DELETE:
            signal = networking.sendOut(commonTransaction: self)
        case .GET_STREAM:
            signal = networking.sendingGetStream(transaction: self)
        case .POST_FORM:
            signal = networking.sendingPostForm(transaction: self)
        case .POST_BODY:
            signal = networking.sendingPostBody(transaction: self)
        case .DOWNLOAD:
            signal = networking.sendingDownload(transaction: self)
        }
        return signal
    }
    
    open func onResponse(response : AnyObject) -> AnyObject? {
        return nil
    }
    
    open func onStream(data: Data) -> AnyObject? {
        return nil
    }
    
}
