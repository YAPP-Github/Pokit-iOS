//
//  SocialLoginInfo.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation

public struct SocialLoginInfo: Equatable {
    let id: String
    /// - 구글로그인에서는 idToken으로 사용
    let authorization: String
    var identityToken: String?
    var name: String?
    var email: String?
    let provider: SocialLoginProvider
}

public extension SocialLoginInfo {
    static let appleMock = SocialLoginInfo(
        id: "",
        authorization: "",
        identityToken: "",
        name: "김민호",
        email: "mino@naver.com",
        provider: .apple
    )
    
    static let googleMock = SocialLoginInfo(
        id: "",
        authorization: "",
        identityToken: "",
        name: "김민호",
        email: "mino@gmail.com",
        provider: .google
    )
}
