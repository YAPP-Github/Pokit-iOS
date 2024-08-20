//
//  AlertClient.swift
//  CoreKit
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

import Dependencies
import Moya

// MARK: - Dependency Values
extension DependencyValues {
    public var alertClient: AlertClient {
        get { self[AlertClient.self] }
        set { self[AlertClient.self] = newValue }
    }
}
/// 알람에 관련한 API를 처리하는 Client
public struct AlertClient {
    public var 알람_목록_조회: @Sendable (BasePageableRequest) async throws -> AlertListInquiryResponse
    public var 알람_삭제: @Sendable (_ alertId: String) async throws -> Void
}

extension AlertClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<AlertEndpoint>.build()

        return Self(
            알람_목록_조회: { model in
                try await provider.request(.알람_목록_조회(model: model))
            },
            알람_삭제: { alertId in
                try await provider.requestNoBody(.알람_삭제(alertId: alertId))
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            알람_목록_조회: { _ in .mock },
            알람_삭제: { _ in }
        )
    }()
}

