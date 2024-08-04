//
//  TokenResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 로그인 API Response / 토큰재발급 API Response 공통
public struct TokenResponse: Decodable {
    public let accessToken: String
    public let refreshToken: String
}

extension TokenResponse {
    public static var mock: Self = Self(
        accessToken: "access(Mock)",
        refreshToken: "refresh(Mock)"
    )
}
