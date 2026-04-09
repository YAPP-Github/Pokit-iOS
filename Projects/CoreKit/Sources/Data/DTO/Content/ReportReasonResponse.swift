//
//  ReportReasonResponse.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Foundation

public struct ReportReasonResponse: Decodable {
    public let code: String
    public let description: String
}

extension ReportReasonResponse {
    public static let mock: Self = .init(code: "SPAM", description: "스팸")
}
