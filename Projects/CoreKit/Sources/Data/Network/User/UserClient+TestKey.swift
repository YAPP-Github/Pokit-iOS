//
//  UserClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension UserClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            닉네임_수정: { _ in .mock },
            회원등록: { _ in .mock },
            닉네임_중복_체크: { _ in .mock },
            관심사_목록_조회: { InterestResponse.mock },
            닉네임_조회: { .mock },
            fcm_토큰_저장: { _ in .mock },
            유저_관심사_목록_조회: { InterestResponse.mock },
            관심사_수정: { _ in }
        )
    }()
}
