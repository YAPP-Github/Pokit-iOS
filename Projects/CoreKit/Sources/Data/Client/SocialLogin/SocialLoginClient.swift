//
//  SocialLoginClient.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import Dependencies

public struct SocialLoginClient {
    var appleLogin: @Sendable () async throws -> SocialLoginInfo
    var googleLogin: @Sendable () async throws -> SocialLoginInfo
}

extension SocialLoginClient: DependencyKey {
    public static let liveValue: Self = {
        let appleLoginController = AppleLoginController()
        let googleLoginController = GoogleLoginController()

        return Self(
            appleLogin: {
                try await appleLoginController.login()
            },
            googleLogin: {
                try await googleLoginController.login()
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            appleLogin: { .appleMock },
            googleLogin: { .googleMock }
            
        )
    }()
}

public extension DependencyValues {
    var socialLogin: SocialLoginClient {
        get { self[SocialLoginClient.self] }
        set { self[SocialLoginClient.self] = newValue }
    }
}
