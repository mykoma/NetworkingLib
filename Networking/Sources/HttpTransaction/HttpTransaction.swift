//
//  HttpTransaction.swift
//  SwiftNetwork
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 qz. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CocoaLumberjack
import Alamofire

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
    
    func outputFilePath() -> NSURL
    
}

// MARK:- HttpTransaction
public class HttpTransaction: NSObject {
    
    class RequestBean: NSObject {
        weak var request: Request?
        var isCancelled: Bool = false
    }
    var currentRequest: RequestBean?
    var rac_subscriber: RACSubscriber?
    
    deinit {
        DDLogInfo("deinit in \(self)")
    }
    
// MARK: Progress
    public var progress: ((Int64, Int64, Int64) -> Void)?
    
// MARK: Cache
    public var needLoadFromCache:Bool = false
    public var needLoadFromCacheIfFailed:Bool = false
    public var needCacheReponse:Bool = false
    
    public func cacheObject() -> HttpResponseCache? {
        return nil
    }
    
    public func toURLRequest() -> NSURLRequest {
        let url = NSURL.init(string: self.url().urlEncoding())
        let mURLRequest = NSMutableURLRequest.init(URL: url!,
                                                   cachePolicy: .UseProtocolCachePolicy,
                                                   timeoutInterval: self.timeoutInterval())
        switch self.httpType() {
        case .DELETE:
            mURLRequest.HTTPMethod = Alamofire.Method.DELETE.rawValue
            break
        case .GET, .GET_STREAM, .DOWNLOAD:
            mURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
            break
        case .PUT:
            mURLRequest.HTTPMethod = Alamofire.Method.PUT.rawValue
            break
        case .POST, .POST_BODY, .POST_FORM:
            mURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
            break
        }
        mURLRequest.allHTTPHeaderFields = self.requestHeaders()
        if self.httpType() == .POST_BODY {
            mURLRequest.HTTPBody = self.httpData()
        }
        return mURLRequest
    }
    
// MARK:- Override
    public func url() -> String {
        var uri = self.baseServerUrl() + self.subUri()
        if uri.containsString("?") {
            uri = uri + "&"
        } else {
            uri = uri + "?"
        }
        uri = uri + self.toSuburiFromParameters()
        return uri
    }

    public func baseServerUrl() -> String {
        DDLogError("Must override >>baseServerUrl<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    public func subUri() -> String {
        DDLogError("Must override >>subUri<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    public func httpType() -> HttpMethodType {
        DDLogError("Must override >>httpType<< in subclass of HttpTransaction")
        self.doesNotRecognizeSelector(#function)
        return HttpMethodType.POST
    }
    
    public func timeoutInterval() -> NSTimeInterval {
        return 60
    }
    
    public func toDictionary() -> [String: String] {
        return [:]
    }
    
    public func requestHeaders() -> [String: String] {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
    
    public func httpMultipartFormName() -> String {
        return ""
    }
    
    public func httpMultipartFormFileName() -> String {
        return ""
    }
    
    public func httpMultipartFormMimeType() -> String {
        return ""
    }
    
    public func httpData() -> NSData? {
        return nil
    }
    
    public func excludeParameters() -> [String] {
        return []
    }
    
    public func send() -> RACSignal {
        var signal: RACSignal
        
        let networking = HttpNetworking.sharedInstance
        
        switch self.httpType() {
        case .GET:
            signal = networking.rac_signalGET(self)
        case .GET_STREAM:
            signal = networking.rac_signalGETStream(self)
        case .POST:
            signal = networking.rac_signalPOST(self)
        case .POST_FORM:
            signal = networking.rac_signalPOSTForm(self)
        case .POST_BODY:
            signal = networking.rac_signalPOSTBody(self)
        case .PUT:
            signal = networking.rac_signalPUT(self)
        case .DOWNLOAD:
            signal = networking.rac_signalDownload(self)
        case .DELETE:
            signal = networking.rac_signalDELETE(self)
        }
        return signal
    }
    
    public func onResponse(response : AnyObject) -> AnyObject? {
        return nil
    }
    
    public func onStream(data: NSData) -> AnyObject? {
        return nil
    }
    
}
