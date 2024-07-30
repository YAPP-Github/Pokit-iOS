//
//  TokenRefresh.swift
//  CoreNetwork
//
//  Created by 김민호 on 7/30/24.
//

import Foundation
/// refresh Token으로 토큰 재발급
public struct PokitTokenRefreshRequest: Encodable {
    let refreshToken: String
}
public struct PokitTokenRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
extension PokitTokenRefreshResponse {
    public static var mock: Self = Self(
        accessToken: "mock(accessToken)",
        refreshToken: "mock(refreshToken)"
    )
}
