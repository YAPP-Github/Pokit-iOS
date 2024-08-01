//
//  TokenInterceptor.swift
//  CoreNetwork
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Alamofire
import Dependencies

/// AccessToken값을 헤더에 넣어주거나, refreshToken으로 Intercept해주는 Interceptor
public final class TokenInterceptor: RequestInterceptor {

    @Dependency(\.keychain) var keychain
    @Dependency(\.authClient) var authClient

    static let shared = TokenInterceptor()
    private init() {}

    /// AccessToken 헤더에 삽입
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard let accessToken = keychain.read(.accessToken) else {
            completion(.success(urlRequest))
            return
        }

        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))

        print("🧤 Intercepted Token : ", accessToken)
    }
    
    /// AccessToken 재발급
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }

        print("🚀 Retry: statusCode: \(response.statusCode)")

        guard let accessToken = keychain.read(.accessToken),
              let refreshToken = keychain.read(.refreshToken) else {
            deleteAllToken()
            completion(.doNotRetryWithError(error))
            return
        }
        let tokenRequest = ReissueRequest(refreshToken: refreshToken)

        Task {
            do {
                let tokenResponse = try await authClient.토큰재발급(tokenRequest)

                keychain.save(.accessToken, tokenResponse.accessToken)
                keychain.save(.refreshToken, tokenResponse.refreshToken)

                completion(.retryWithDelay(1))
            } catch {
                deleteAllToken()
                completion(.doNotRetryWithError(error))
            }
        }
    }

    private func deleteAllToken() {
        keychain.delete(.accessToken)
        keychain.delete(.refreshToken)
    }
}
