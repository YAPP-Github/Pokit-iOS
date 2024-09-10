//
//  VersionResponse.swift
//  CoreKit
//
//  Created by 김민호 on 9/10/24.
//

import Foundation

public struct VersionResponse: Decodable {
    public let recentVersion: String
}

extension VersionResponse {
    static let mock: Self = Self(recentVersion: "1.0.0")
}
