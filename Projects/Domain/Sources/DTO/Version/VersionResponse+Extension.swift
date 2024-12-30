//
//  VersionResponse+Extension.swift
//  Domain
//
//  Created by 김민호 on 12/30/24.
//

import Foundation

import CoreKit

public extension VersionResponse {
    func toDomain() -> Version {
        return .init(
            self.results.first?.version ?? "",
            trackId: self.results.first?.trackId ?? 0
        )
    }
}
