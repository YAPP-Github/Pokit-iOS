//
//  NicknameCheckResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

import CoreKit

public extension NicknameCheckResponse {
    func toDomain() -> Bool {
        return self.isDuplicate
    }
}
