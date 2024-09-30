//
//  AlertClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import Moya

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
}
