//
//  SocialLoginInfo.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation

public struct SocialLoginInfo: Equatable {
    let id: String
    let authorization: String
    var identityToken: String?
    var name: String?
    var email: String?
    let provider: SocialLoginProvider
}

public extension SocialLoginInfo {
    static let mock = SocialLoginInfo(
        id: "",
        authorization: "",
        identityToken: "",
        name: "김민호",
        email: "mino@naver.com",
        provider: .apple
    )
}
