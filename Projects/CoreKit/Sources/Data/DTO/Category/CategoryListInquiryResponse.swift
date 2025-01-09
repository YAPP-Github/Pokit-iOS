//
//  CategoryListInquiryResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Util
/// 포킷 목록 조회 API Response
public struct CategoryListInquiryResponse: Decodable {
    public let data: [CategoryItemInquiryResponse]
    public let page: Int
    public let size: Int
    public let sort: [ItemInquirySortResponse]
    public let hasNext: Bool
}

/// Data
public struct CategoryItemInquiryResponse: Decodable {
    public let categoryId: Int
    public let userId: Int
    public let categoryName: String
    public let categoryImage: CategoryImageResponse
    public let contentCount: Int
    public let createdAt: String
    public let openType: String
    public let keywordType: String
    public let userCount: Int
}
/// Sort
public struct ItemInquirySortResponse: Decodable {
    public let direction: String
    public let nullHandling: String
    public let ascending: Bool
    public let property: String
    public let ignoreCase: Bool
}

public extension CategoryItemInquiryResponse {
    static var mock: Self = CategoryItemInquiryResponse(
        categoryId: 3,
        userId: 5555555,
        categoryName: "카테고리1",
        categoryImage: CategoryImageResponse(
            imageId: 22312,
            imageUrl: Constants.mockImageUrl
        ),
        contentCount: 90,
        createdAt: "",
        openType: "PRIVATE",
        keywordType: "스포츠/레저",
        userCount: 0
    )
}

extension CategoryListInquiryResponse {
    public static var mock: Self = Self(
        data: [
            CategoryItemInquiryResponse(
                categoryId: 1,
                userId: 5555555,
                categoryName: "카테고리1",
                categoryImage: CategoryImageResponse(
                    imageId: 22312,
                    imageUrl: Constants.mockImageUrl
                ),
                contentCount: 90,
                createdAt: "",
                openType: "PRIVATE",
                keywordType: "스포츠/레저",
                userCount: 0
            ),
            CategoryItemInquiryResponse(
                categoryId: 2,
                userId: 5555555,
                categoryName: "카테고리1",
                categoryImage: CategoryImageResponse(
                    imageId: 22312,
                    imageUrl: Constants.mockImageUrl
                ),
                contentCount: 90,
                createdAt: "",
                openType: "PUBLIC",
                keywordType: "스포츠/레저",
                userCount: 1
            ),
            CategoryItemInquiryResponse(
                categoryId: 3,
                userId: 5555555,
                categoryName: "카테고리1",
                categoryImage: CategoryImageResponse(
                    imageId: 22312,
                    imageUrl: Constants.mockImageUrl
                ),
                contentCount: 90,
                createdAt: "",
                openType: "PUBLIC",
                keywordType: "스포츠/레저",
                userCount: 5
            )
        ],
        page: 1,
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
