//
//  ContentBaseResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 컨텐츠 상세조회, 컨텐츠 수정, 컨텐츠 추가 API Response
public struct ContentBaseResponse: Decodable {
    public let contentId: Int
    public let categoryId: Int
    public let categoryName: String
    public let data: String
    public let title: String
    public let thumbNail: String
    public let memo: String
    public let alertYn: String
    public let createdAt: String
    public let isRead: Bool
    public let favorites: Bool
}

extension ContentBaseResponse {
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
        isRead: false,
        favorites: true
    )
}
