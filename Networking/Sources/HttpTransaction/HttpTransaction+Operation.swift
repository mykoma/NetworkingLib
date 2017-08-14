//
//  HttpTransaction+RequestOperation.swift
//  Networking
//
//  Created by Apple on 2016/11/4.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation

// MARK: - Operations

extension HttpTransaction {
    
    public func cancel() {
        self.currentRequest?.request?.cancel()
        self.currentRequest?.isCancelled = true
    }
    
    public func suspend() {
        self.currentRequest?.request?.suspend()
    }
    
    public func resume() {
        self.currentRequest?.request?.resume()
    }
}

// MARK: - Download

var HttpTransaction_Download_ResumeData: UInt8 = 0

extension HttpTransaction {
    
    var resumeData: NSData? {
        get {
            return objc_getAssociatedObject(self,
                                            &HttpTransaction_Download_ResumeData) as? NSData
        }
        set {
            objc_setAssociatedObject(self,
                                     &HttpTransaction_Download_ResumeData,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func suspendDownload() {
        self.cancel()
    }
    
    public func resumeDownload() {
        HttpNetworking.sharedInstance
            .rac_signalDownloadResume(self)
            .subscribeNext({ [weak self](a: AnyObject!) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.rac_subscriber?.sendNext(a)
                }, error: { [weak self](error: NSError!) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.rac_subscriber?.sendError(error)
            }) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.rac_subscriber?.sendCompleted()
        }
    }
    
}
