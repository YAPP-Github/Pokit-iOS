//
//  AuthClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies
import Moya

extension AuthClient: DependencyKey {
    public static let liveValue: Self = {
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
            },
            appleRevoke: { refreshToken, model in
                try await nonTokenProvider.requestNoBody(.appleRevoke(refreshToken, model))
            }
        )
    }()
}
