//
//  AuthClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Dependencies
import Moya

// MARK: - Dependency Values
extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
/// 유저정보에 관련한 API를 처리하는 Client
public struct AuthClient {
    public var 로그인: @Sendable (SignInRequest) async throws -> TokenResponse
    public var 회원탈퇴: @Sendable (WithdrawRequest) async throws -> Void
    public var 토큰재발급: @Sendable (ReissueRequest) async throws -> ReissueResponse
    public var apple: @Sendable (AppleTokenRequest) async throws -> AppleTokenResponse
}

extension AuthClient: DependencyKey {
    public static let liveValue: Self = {
        /// 로그인 api (자동로그인 / 로그인)용 access token이 필요없을 때 사용하는 provider
        let nonTokenProvider = MoyaProvider<AuthEndpoint>.buildNonToken()
        let provider = MoyaProvider<AuthEndpoint>.build()

        return Self(
            로그인: { model in
                try await nonTokenProvider.request(.로그인(model))
            },
            회원탈퇴: { model in
                try await provider.requestNoBody(.회원탈퇴(model))
            },
            토큰재발급: { model in
                try await nonTokenProvider.request(.토큰재발급(model))
            },
            apple: { model in
                try await nonTokenProvider.request(.apple(model))
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            로그인: { _ in .mock },
            회원탈퇴: { _ in  },
            토큰재발급: { _ in .mock },
            apple: { _ in .init(refresh_token: "") }
        )
    }()
}
