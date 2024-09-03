//
//  UserClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Dependencies
import Moya

extension DependencyValues {
    public var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
/// Category에 관련한 API를 처리하는 Client
public struct UserClient {
    public var 닉네임_수정: @Sendable (_ model: NicknameEditRequest) async throws -> BaseUserResponse
    public var 회원등록: @Sendable (_ model: SignupRequest) async throws -> BaseUserResponse
    public var 닉네임_중복_체크: @Sendable (_ nickname: String) async throws -> NicknameCheckResponse
    public var 관심사_목록_조회: @Sendable () async throws -> [InterestResponse]
    public var 닉네임_조회: @Sendable () async throws -> BaseUserResponse
    public var fcm_토큰_저장: @Sendable (_ model: FCMRequest) async throws -> FCMResponse
}

extension UserClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<UserEndpoint>.build()

        return Self(
            닉네임_수정: { model in
                try await provider.request(.닉네임_수정(model: model))
            },
            회원등록: { model in
                try await provider.request(.회원등록(model: model))
            },
            닉네임_중복_체크: { nickname in
                try await provider.request(.닉네임_중복_체크(nickname: nickname))
            },
            관심사_목록_조회: {
                try await provider.request(.관심사_목록_조회)
            },
            닉네임_조회: {
                try await provider.request(.닉네임_조회)
            },
            fcm_토큰_저장: { model in
                try await provider.request(.fcm_토큰_저장(model: model))
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            닉네임_수정: { _ in .mock },
            회원등록: { _ in .mock },
            닉네임_중복_체크: { _ in .mock },
            관심사_목록_조회: { InterestResponse.mock },
            닉네임_조회: { .mock },
            fcm_토큰_저장: { _ in .mock }
        )
    }()
}
