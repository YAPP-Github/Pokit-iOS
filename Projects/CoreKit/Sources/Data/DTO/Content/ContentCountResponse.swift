//
//  UnreadCountResponse.swift
//  CoreKit
//
//  Created by 김도형 on 9/21/24.
//

import Foundation

public struct BookmarkCountResponse: Decodable {
    let count: Int
}

public struct UnreadCountResponse: Decodable {
    let count: Int
}

extension UnreadCountResponse {
    static let mock: UnreadCountResponse = .init(count: 10)
}

extension BookmarkCountResponse {
    static let mock: BookmarkCountResponse = .init(count: 10)
}

extension UnreadCountResponse {
    enum CodingKeys: String, CodingKey {
        case count = "unreadContentCount"
    }
}

extension BookmarkCountResponse {
    enum CodingKeys: String, CodingKey {
        case count = "bookmarkContentCount"
    }
}
