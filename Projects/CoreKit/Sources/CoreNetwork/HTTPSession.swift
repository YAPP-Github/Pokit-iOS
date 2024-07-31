//
//  HTTPSession.swift
//  CoreNetwork
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Moya

public final class HTTPSession {
    static let shared = HTTPSession()
    
    private init() {}
    
    let session: Moya.Session = {
        let session = Moya.Session(interceptor: TokenInterceptor.shared)
        return session
    }()
}
