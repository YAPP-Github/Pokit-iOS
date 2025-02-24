//
//  UserClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import Moya

extension UserClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<UserEndpoint>.build()

        return Self(
            프로필_수정: { model in
                try await provider.request(.프로필_수정(model: model))
            },
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
            },
            유저_관심사_목록_조회: {
                try await provider.request(.유저_관심사_목록_조회)
            }
        )
    }()
}
