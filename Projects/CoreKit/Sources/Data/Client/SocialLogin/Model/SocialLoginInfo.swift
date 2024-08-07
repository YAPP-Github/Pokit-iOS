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
}

public extension SocialLoginInfo {
    static let appleMock = SocialLoginInfo(
        idToken: "",
        provider: .apple
    )
    
    static let googleMock = SocialLoginInfo(
        idToken: "",
        provider: .google
    )
}
