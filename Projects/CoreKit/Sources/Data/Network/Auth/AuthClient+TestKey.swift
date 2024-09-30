//
//  AuthClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension AuthClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            로그인: { _ in .mock },
            회원탈퇴: { _ in  },
            토큰재발급: { _ in .mock },
            apple: { _ in .init(refresh_token: "") },
            appleRevoke: { _, _ in }
        )
    }()
}
