//
//  ReportReasonResponse+Extension.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import CoreKit

public extension ReportReasonResponse {
    func toDomain() -> BaseReportReason {
        .init(code: self.code, description: self.description)
    }
}

public extension Array where Element == ReportReasonResponse {
    func toDomain() -> [BaseReportReason] {
        map { $0.toDomain() }
    }
}
