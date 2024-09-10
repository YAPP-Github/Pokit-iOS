//
//  VersionClient.swift
//  CoreKit
//
//  Created by 김민호 on 9/10/24.
//

import Foundation

import Dependencies
import Moya

// MARK: - Dependency Values
extension DependencyValues {
    public var versionClient: VersionClient {
        get { self[VersionClient.self] }
        set { self[VersionClient.self] = newValue }
    }
}
/// 알람에 관련한 API를 처리하는 Client
public struct VersionClient {
    public var 버전체크: @Sendable () async throws -> VersionResponse
}

extension VersionClient: DependencyKey {
    public static let liveValue: Self = {
        let nonProvider = MoyaProvider<VersionEndpoint>.buildNonToken()

        return Self(
            버전체크: {
                try await nonProvider.request(.버전체크)
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            버전체크: { .mock }
        )
    }()
}

