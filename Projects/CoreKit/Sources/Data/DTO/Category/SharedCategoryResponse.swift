//
//  SharedCategoryResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct SharedCategoryResponse: Decodable {
    public let category: Category
    public var contents: ContentListInquiryResponse
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
}
