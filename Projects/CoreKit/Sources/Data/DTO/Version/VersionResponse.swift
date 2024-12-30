//
//  VersionResponse.swift
//  CoreKit
//
//  Created by 김민호 on 9/10/24.
//

import Foundation

public struct VersionResponse: Decodable {
    public let results: [VersionDTO]
}

public struct VersionDTO: Decodable {
    public let version: String
    public let trackId: Int
}

extension VersionResponse {
    static let mock: Self = Self(results: [VersionDTO(version: "1.0.0", trackId: 2415354644)])
}
