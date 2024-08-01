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
    let categoryId: Int
    let categoryName: String
    let categoryImage: CategoryImageResponse
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
    let imageId: Int
    let imageUrl: String
}

extension CategoryImageResponse {
    public static var mock: [Self] = [
        Self(
            imageId: 2312,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 23122,
            imageUrl: Constants.mockImageUrl
        ),
    ]
}
