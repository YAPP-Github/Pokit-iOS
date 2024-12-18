//
//  CategoryEditResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Util
/// 포킷 수정 API Response
public struct CategoryEditResponse: Decodable {
    public let categoryId: Int
    public let categoryName: String
    public let categoryImage: CategoryImageResponse
}

extension CategoryEditResponse {
    public static var mock: Self = Self(
        categoryId: 5590,
        categoryName: "마음이 편안해지는 책모음",
        categoryImage: CategoryImageResponse(
            imageId: 4441,
            imageUrl: Constants.mockImageUrl
        )
    )
}

public struct CategoryImageResponse: Decodable {
    public let imageId: Int
    public let imageUrl: String
}

extension CategoryImageResponse {
    public static var mock: [Self] = [
        Self(
            imageId: 2312,
            imageUrl: Constants.기본_썸네일_주소.absoluteString
        ),
        Self(
            imageId: 23122,
            imageUrl: Constants.mockImageUrl
        ),
    ]
}
