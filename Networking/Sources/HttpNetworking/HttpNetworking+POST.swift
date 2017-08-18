//
//  HttpNetworking+POST.swift
//  Networking
//
//  Created by Apple on 2016/11/1.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

extension HttpNetworking {
    
    // MARK: POST WITH BODY
    func sendingPostBody(transaction: HttpTransaction) -> Observable<Any> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: transaction,
                               observer: observer,
                               sendingBlock:
                {
                    strongSelf.logSending(transaction: transaction)
                    let requestBean = HttpTransaction.RequestBean()
                    transaction.currentRequest = requestBean
                    let data = transaction.httpData() ?? Data.init()
                    requestBean.request = Alamofire.upload(data, with: transaction.toURLRequest())
                        .uploadProgress(closure: { (p: Progress) in
                            transaction.onProgress?(p)
                        }).responseJSON(completionHandler: { (resp) in
                            strongSelf.process(response: resp,
                                               transaction: transaction,
                                               observer: observer)
                        })
            })
            return Disposables.create()
        })
    }
    
    // MARK: POST WITH FORM
    func sendingPostForm(transaction: HttpTransaction) -> Observable<Any> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            strongSelf.process(transaction: transaction,
                               observer: observer,
                               sendingBlock:
                {
                    strongSelf.logSending(transaction: transaction)
                    Alamofire.upload(multipartFormData: { (form) in
                        if let data = transaction.httpData() {
                            form.append(data,
                                        withName: transaction.httpMultipartFormName(),
                                        fileName: transaction.httpMultipartFormFileName(),
                                        mimeType: transaction.httpMultipartFormMimeType())
                        }
                    }, with: transaction.toURLRequest(),
                       encodingCompletion: { (encodingResult) in
                        switch encodingResult {
                        case .success(let request, _, _):
                            request.uploadProgress(closure: { (p) in
                                transaction.onProgress?(p)
                            }).responseJSON(completionHandler: { (resp) in
                                strongSelf.process(response: resp,
                                                   transaction: transaction,
                                                   observer: observer)
                            })
                        case .failure(let encodingError):
                            print(encodingError)
                            observer.onError(encodingError)
                        }
                    })
                }
            )
            return Disposables.create()
        })
    }

}
