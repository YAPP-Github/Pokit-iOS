//
//  SocialLoginError.swift
//  CoreKit
//
//  Created by 김민호 on 7/1/24.
//

import Foundation

public enum SocialLoginError: Error {
    case invalidCredential
    case transferError(String)
    case appleLoginError(AppleLoginError)
    case googleLoginError(GoogleLoginError)
}

public enum GoogleLoginError: Error {
    case invalidIdToken
}

public enum AppleLoginError: Error {
    case invalidIdentityToken
    case invalidAuthorizationCode
}
