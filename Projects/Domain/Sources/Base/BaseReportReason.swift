//
//  BaseReportReason.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

public struct BaseReportReason: Equatable {
    public let code: String
    public let description: String

    public init(code: String, description: String) {
        self.code = code
        self.description = description
    }
}
