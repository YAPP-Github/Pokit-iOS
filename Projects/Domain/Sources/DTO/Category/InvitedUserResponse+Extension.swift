//
//  InvitedUserResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 12/25/25.
//

import Foundation

import CoreKit

public extension InvitedUserResponse {
    func toDomain() -> InvitedUser {
        return .init(
            id: self.userId,
            nickname: self.nickname,
            profile: self.profileImage?.toDomain()
        )
    }
}
