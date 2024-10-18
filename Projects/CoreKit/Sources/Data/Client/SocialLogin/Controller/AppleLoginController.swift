//
//  AppleLoginController.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import AuthenticationServices
import SwiftJWT

public final class AppleLoginController: NSObject, ASAuthorizationControllerDelegate {
    
    private var continuation: CheckedContinuation<SocialLoginInfo, Error>?
    
    public func login() async throws -> SocialLoginInfo {
        try await withCheckedThrowingContinuation { continuation in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
            
            if self.continuation == nil {
                self.continuation = continuation
            }
        }
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: SocialLoginError.invalidCredential)
            continuation = nil
            return
        }
        
        
        guard let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            continuation?.resume(throwing: SocialLoginError.appleLoginError(.invalidIdentityToken))
            continuation = nil
            return
        }
        
        guard let authorizationCode = credential.authorizationCode,
              let codeString = String(data: authorizationCode, encoding: .utf8) else {
            continuation?.resume(throwing: SocialLoginError.appleLoginError(.invalidAuthorizationCode))
            continuation = nil
            return
        }
        print("🍎 [appleLogin] token: \(token)")
        print("🍎 [appleLogin] authorizationCode: \(codeString)")
        
        let secretKey = self.makeJWT()
        
        
        let info = SocialLoginInfo(
            idToken: token,
            provider: .apple,
            serverRefreshToken: codeString,
            jwt: secretKey,
            authCode: codeString
        )
        continuation?.resume(returning: info)
        continuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleLoginController {
    func makeJWT() -> String {
        guard let appleKey = Bundle.module.object(forInfoDictionaryKey: "AppleKeyID") as? String else { return "" }
        let header = Header(kid: appleKey)
        struct PokitClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        guard let iss = Bundle.module.object(forInfoDictionaryKey: "TeamID") as? String else { return "" }
        let claims = PokitClaims(
            iss: iss,
            iat: iat,
            exp: exp,
            aud: "https://appleid.apple.com",
            sub: "com.pokitmons.pokit"
        )
        
        var myJWT = JWT(header: header, claims: claims)
        let bundle = Bundle(for: type(of: self))
//        guard let authKeyName = Bundle.main.object(forInfoDictionaryKey: "AuthKey") as? String else { return "" }
        guard let url = bundle.url(forResource: "AuthKey", withExtension: "p8") else {
            return "못찾음"
        }
        let privateKey: Data = try! Data(contentsOf: url, options: .alwaysMapped)
        
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        return signedJWT
    }
}
