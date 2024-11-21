//
//  VersionClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies
import Moya

extension VersionClient: DependencyKey {
    public static let liveValue: Self = {
        let nonProvider = MoyaProvider<VersionEndpoint>.buildNonToken()

        return Self(
            버전체크: {
                try await nonProvider.request(.버전체크)
            }
        )
    }()
}
