//
//  FCMResponse.swift
//  CoreKit
//
//  Created by 김민호 on 8/27/24.
//

import Foundation

public struct FCMResponse: Decodable {
    public let userId: Int
    public let token: String
}

extension FCMResponse {
    static let mock: Self = Self(userId: 339, token: "token(mock)")
}
