//
//  ContentReportRequest.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Foundation

public struct ContentReportRequest: Encodable {
    public let reportReason: String

    public init(reportReason: String) {
        self.reportReason = reportReason
    }
}
