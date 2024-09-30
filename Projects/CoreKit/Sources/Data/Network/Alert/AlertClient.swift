//
//  AlertClient.swift
//  CoreKit
//
//  Created by 김민호 on 8/17/24.
//

import DependenciesMacros

@DependencyClient
public struct AlertClient {
    public var 알람_목록_조회: @Sendable (BasePageableRequest) async throws -> AlertListInquiryResponse
    public var 알람_삭제: @Sendable (_ alertId: String) async throws -> Void
}


