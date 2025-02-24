//
//  BaseUserResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/25/24.
//

import Foundation

import CoreKit

public extension BaseUserResponse {
    func toDomain() -> BaseUser {
        return .init(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            profile: self.profileImage == nil
            ? nil
            : BaseProfile(id: self.profileImage?.id ?? 0, url: self.profileImage?.url ?? "")
        )
    }
}
