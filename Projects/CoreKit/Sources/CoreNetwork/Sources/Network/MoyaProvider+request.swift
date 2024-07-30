//
//  MoyaProvider+request.swift
//  CoreKit
//
//  Created by 김민호 on 7/30/24.
//

import Foundation
import Moya

public struct ErrorResponse: Error, Decodable {
    let message: String
    let code: String
    static let base = ErrorResponse(message: "기본에러입니다", code: "CODE")
}

extension MoyaProvider {
    func request<T: Decodable>(_ target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { response in
                switch response {
                case .success(let result):
                    do {
                        let networkResponse = try JSONDecoder().decode(T.self, from: result.data)
                        continuation.resume(returning: networkResponse)
                    } catch {
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: result.data)
                        continuation.resume(throwing: errorResponse ?? .base)
                    }

                case .failure(let error):
                    if let response = error.response?.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response)
                        continuation.resume(throwing: errorResponse ?? .base)
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
