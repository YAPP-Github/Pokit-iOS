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
    let data: [CategoryItemInquiryResponse]
    let page: Int
    let size: Int
    let sort: [CategoryListInquirySortResponse]
    let hasNext: Bool
}

/// Data
public struct CategoryItemInquiryResponse: Decodable {
    let categoryId: Int
    let userId: Int
    let categoryName: String
    let categoryImage: CategoryImageResponse
    let contentCount: Int
}
/// Sort
public struct CategoryListInquirySortResponse: Decodable {
    let direction: String
    let nullHandling: String
    let ascending: Bool
    let property: String
    let ignoreCase: Bool
}

extension CategoryListInquiryResponse {
    public static var mock: Self = Self(
        data: [
            CategoryItemInquiryResponse(
                categoryId: 3,
                userId: 5555555,
                categoryName: "카테고리1",
                categoryImage: CategoryImageResponse(
                    imageId: 22312,
                    imageUrl: Constants.mockImageUrl
                ),
                contentCount: 90
            )
        ],
        page: 1,
        size: 4,
        sort: [
            CategoryListInquirySortResponse(
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
