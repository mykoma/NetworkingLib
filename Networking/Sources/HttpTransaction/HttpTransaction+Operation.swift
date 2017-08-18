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
    
    var resumeData: Data? {
        get {
            return objc_getAssociatedObject(self,
                                            &HttpTransaction_Download_ResumeData) as? Data
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
        let _ = HttpNetworking.sharedInstance
            .sendingDownloadResume(transaction: self)
            .subscribe(onNext: { [weak self](resp) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.rxObserver?.onNext(resp)
                }, onError: { [weak self](error) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.rxObserver?.onError(error)
                }, onCompleted: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.rxObserver?.onCompleted()
            }) {
                // Dispose
        }
    }
    
}
