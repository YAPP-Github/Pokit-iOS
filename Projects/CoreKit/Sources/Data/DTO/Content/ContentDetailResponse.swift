//
//  ContentDetailResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public struct ContentDetailResponse: Decodable {
    public let contentId: Int
    public let categoryId: Int
    public let categoryName: String
    public let data: String
    public let title: String
    public let thumbNail: String
    public let memo: String
    public let alertYn: String
    public let createdAt: String
    public let favorites: Bool
}

extension ContentDetailResponse {
    public static var mock: Self = Self(
        contentId: 512,
        categoryId: 992,
        categoryName: "미분류",
        data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
        title: "Title(Mock)",
        thumbNail: "https://picsum.photos/200/300​",
        memo: "MEMO(Mock)",
        alertYn: "AAAA",
        createdAt: "2024-07-31T10:10:23.902Z",
        favorites: true
    )
}
