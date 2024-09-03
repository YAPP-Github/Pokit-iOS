//
//  TokenResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 로그인 API Response
public struct TokenResponse: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let isRegistered: Bool
}

extension TokenResponse {
    public static var mock: Self = Self(
        accessToken: "access(Mock)",
        refreshToken: "refresh(Mock)",
        isRegistered: false
    )
}
