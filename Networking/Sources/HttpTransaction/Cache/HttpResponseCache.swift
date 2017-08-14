//
//  HttpResponseCache.swift
//  CrazyPanda
//
//  Created by apple on 16/7/14.
//  Copyright © 2016年 Goluk. All rights reserved.
//

import Foundation

public protocol HttpResponseCache {
    /**
     *  Load Response
     */
    func loadResponse() -> AnyObject?
    /**
     *  Cache Response
     */
    func cacheResponse(response: AnyObject!) 
    
}
