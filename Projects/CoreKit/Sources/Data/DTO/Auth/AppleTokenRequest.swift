//
//  AppleTokenRequest.swift
//  CoreKit
//
//  Created by 김민호 on 8/12/24.
//

import Foundation
/// Refresh Token을 얻기위한 Request
public struct AppleTokenRequest: Encodable {
    public let authCode: String
    public let jwt: String
    
    public init(authCode: String, jwt: String) {
        self.authCode = authCode
        self.jwt = jwt
    }
}

