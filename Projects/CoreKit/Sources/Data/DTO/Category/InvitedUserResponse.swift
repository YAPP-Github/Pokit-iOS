//
//  InvitedUserResponse.swift
//  CoreKit
//
//  Created by 김도형 on 12/25/25.
//

import Foundation

public struct InvitedUserResponse: Decodable {
    public let userId: Int
    public let nickname: String
    public let profileImage: BaseProfileImageResponse?
}

extension InvitedUserResponse {
    public static var mock: Self = Self(
        userId: 1,
        nickname: "PokitUser",
        profileImage: .mock
    )
}
