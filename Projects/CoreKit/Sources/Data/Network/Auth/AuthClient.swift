//
//  AuthClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import DependenciesMacros

@DependencyClient
public struct AuthClient {
    public var 로그인: @Sendable (SignInRequest) async throws -> TokenResponse
    public var 회원탈퇴: @Sendable (WithdrawRequest) async throws -> Void
    public var 토큰재발급: @Sendable (ReissueRequest) async throws -> ReissueResponse
    public var apple: @Sendable (AppleTokenRequest) async throws -> AppleTokenResponse
    public var appleRevoke: @Sendable (String, AppleTokenRequest) async throws -> Void
}

