//
//  SocialLoginInfo.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation

public struct SocialLoginInfo: Equatable {
    public var idToken: String?
    public let provider: SocialLoginProvider
    public let serverRefreshToken: String
    public let jwt: String?
    public let authCode: String?
}

public extension SocialLoginInfo {
    static let appleMock = SocialLoginInfo(
        idToken: "",
        provider: .apple, 
        serverRefreshToken: "",
        jwt: "",
        authCode: ""
    )
    
    static let googleMock = SocialLoginInfo(
        idToken: "",
        provider: .google,
        serverRefreshToken: "",
        jwt: nil,
        authCode: nil
    )
}
