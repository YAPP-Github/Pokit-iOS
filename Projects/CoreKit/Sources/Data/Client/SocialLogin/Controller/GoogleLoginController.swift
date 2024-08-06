//
//  GoogleLoginController.swift
//  CoreKit
//
//  Created by 김민호 on 6/27/24.
//

import Foundation
import GoogleSignIn

public final class GoogleLoginController {
    private var continuation: CheckedContinuation<SocialLoginInfo, Error>?
    
    @MainActor
    public func login() async throws -> SocialLoginInfo {
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            googleSignIn()
        }
    }
    
    private func googleSignIn() {
        guard let root = UIApplication.shared.rootViewController else {
            continuation?.resume(throwing: SocialLoginError.transferError("Root view does not exist."))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: root) { [weak self] signInResult, error in
            guard let self else { return }
            if let error {
                continuation?.resume(throwing: error)
                continuation = nil
                return
            }

            guard let result = signInResult else {
                continuation?.resume(throwing: SocialLoginError.invalidCredential)
                continuation = nil
                return
            }
            
            guard let idToken = result.user.idToken else {
                continuation?.resume(throwing: SocialLoginError.googleLoginError(.invalidIdToken))
                continuation = nil
                return
            }
            print("🌐 googleLogin idToken: \(idToken)")

            let info = SocialLoginInfo(
                idToken: idToken.tokenString,
                provider: .google
            )
            continuation?.resume(returning: info)
        }
    }
}

