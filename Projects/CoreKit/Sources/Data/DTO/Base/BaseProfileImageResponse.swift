//
//  BaseProfileImageResponse.swift
//  CoreKit
//
//  Created by 김민호 on 2/25/25.
//

import Util

public struct BaseProfileImageResponse: Decodable {
    public let id: Int
    public let url: String
}

extension BaseProfileImageResponse {
    static let mock: Self = Self(id: 999, url: Constants.mockImageUrl)
}
