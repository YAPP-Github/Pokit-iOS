//
//  UserClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import DependenciesMacros

@DependencyClient
public struct UserClient {
    public var 프로필_수정: @Sendable (_ model: ProfileEditRequest) async throws -> BaseUserResponse
    public var 닉네임_수정: @Sendable (_ model: NicknameEditRequest) async throws -> BaseUserResponse
    public var 회원등록: @Sendable (_ model: SignupRequest) async throws -> BaseUserResponse
    public var 닉네임_중복_체크: @Sendable (_ nickname: String) async throws -> NicknameCheckResponse
    public var 관심사_목록_조회: @Sendable () async throws -> [InterestResponse]
    public var 닉네임_조회: @Sendable () async throws -> BaseUserResponse
    public var fcm_토큰_저장: @Sendable (_ model: FCMRequest) async throws -> FCMResponse
    public var 유저_관심사_목록_조회: @Sendable () async throws -> [InterestResponse]
}
