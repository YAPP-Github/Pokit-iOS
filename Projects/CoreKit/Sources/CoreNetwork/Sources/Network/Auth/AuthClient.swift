//
//  AuthClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Dependencies
import Moya

public struct Dummy: Codable {}
public struct DummyBody: Encodable {}

// MARK: - Dependency Values
extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
/// 유저정보에 관련한 API를 처리하는 Client
public struct AuthClient {
    /// 로그인
    var login: @Sendable (DummyBody) async throws -> Dummy
    /// 토큰 재발급
    var reissueToken: @Sendable (PokitTokenRefreshRequest) async throws -> PokitTokenRefreshResponse
}

extension AuthClient: DependencyKey {
    public static let liveValue: Self = {
        /// 로그인 api (자동로그인 / 로그인)용 access token이 필요없을 때 사용하는 provider
        let nonTokenProvider = MoyaProvider<AuthEndpoint>.buildNonToken()
        let provider = MoyaProvider<AuthEndpoint>.build()

        return Self(
            login: { dum in
                try await nonTokenProvider.request(.login(dum))
            },
            reissueToken: {
                try await provider.request(.reissueToken(reqeust: $0))
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            login: { _ in  Dummy.init() },
            reissueToken: { _ in .mock }
        )
    }()
}
