//
//  SocialLoginClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies

extension SocialLoginClient: DependencyKey {
    public static let liveValue: Self = {
        let appleLoginController = AppleLoginController()
        let googleLoginController = GoogleLoginController()
        
        return Self(
            appleLogin: {
                try await appleLoginController.login()
            },
            googleLogin: { root in
                try await googleLoginController.login(root: root)
            },
            getClientSceret: {
                return appleLoginController.makeJWT()
            }
        )
    }()
}
