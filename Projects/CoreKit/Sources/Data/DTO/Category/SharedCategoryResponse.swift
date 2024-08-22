//
//  SharedCategoryResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct SharedCategoryResponse: Decodable {
    public let category: Category
    public var contents: Self.ContentListInquiry
}

extension SharedCategoryResponse {
    public static var mock: Self = .init(
        category: .init(
            categoryId: 0,
            categoryName: "카테고리_이름임",
            contentCount: 3),
        contents: .mock
    )
}

extension SharedCategoryResponse {
    public struct Category: Decodable {
        public let categoryId: Int
        public let categoryName: String
        public let contentCount: Int
    }
    
    public struct ContentListInquiry: Decodable {
        public let data: [SharedCategoryResponse.Content]
        public let page: Int
        public let size: Int
        public let sort: [ItemInquirySortResponse]
        public let hasNext: Bool
    }
    
    public struct Content: Decodable {
        public let contentId: Int
        public let data: String
        public let domain: String
        public let title: String
        public let thumbNail: String
        public let createdAt: String
    }
}

extension SharedCategoryResponse.Content {
    public static func mock(id: Int) -> Self {
        Self(
            contentId: id,
            data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
            domain: "youtube",
            title: "신서유기",
            thumbNail: "https://i.ytimg.com/vi/NnOC4_kH0ok/hqdefault.jpg?sqp=-oaymwEjCNACELwBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDN6u6mTjbaVmRZ4biJS_aDq4uvAQ",
            createdAt: "2024.08.08"
        )
    }
}

extension SharedCategoryResponse.ContentListInquiry {
    public static var mock: Self = Self(
        data: [
            SharedCategoryResponse.Content.mock(id: 0),
            SharedCategoryResponse.Content.mock(id: 1),
            SharedCategoryResponse.Content.mock(id: 2)
        ],
        page: 0,
        size: 4,
        sort: [
            ItemInquirySortResponse(
                direction: "",
                nullHandling: "",
                ascending: false,
                property: "",
                ignoreCase: false
            )
        ],
        hasNext: false
    )
}
