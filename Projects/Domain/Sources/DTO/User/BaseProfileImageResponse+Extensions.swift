//
//  BaseProfileImageResponse+Extensions.swift
//  Domain
//
//  Created by 김민호 on 2/25/25.
//

import Foundation

import CoreKit

public extension BaseProfileImageResponse {
    func toDomain() -> BaseProfile {
        return .init(id: self.id, imageURL: self.url)
    }
}
