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
    var 닉네임_수정: @Sendable (_ model: NicknameEditRequest) async throws -> BaseUserResponse
    var 회원등록: @Sendable (_ model: SignupRequest) async throws -> BaseUserResponse
    var 닉네임_중복_체크: @Sendable (_ nickname: String) async throws -> NicknameCheckResponse
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
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            닉네임_수정: { _ in .mock },
            회원등록: { _ in .mock },
            닉네임_중복_체크: { _ in .mock }
        )
    }()
}
