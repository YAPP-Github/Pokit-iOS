//
//  CategorySettingMock.swift
//  FeatureCategorySetting
//
//  Created by 김민호 on 7/25/24.
//

import Foundation
import Util

public struct CategorySettingMock: Equatable {
    let categoryId: Int
    let categoryName: String
    /// var: 포킷 수정 / 추가에서 이미지를 할당할 수 있음
    var categoryImage: CategorySettingImageMock
}

public struct CategorySettingImageMock: Equatable {
    let imageId: Int
    let imageUrl: String
    
    public init(imageId: Int, imageUrl: String) {
        self.imageId = imageId
        self.imageUrl = imageUrl
    }
}

extension CategorySettingMock {
    static var mock: Self = Self(
        categoryId: 0,
        categoryName: "대충 포킷명",
        categoryImage: CategorySettingImageMock(
            imageId: 1,
            imageUrl: Constants.mockImageUrl
        )
    )
}

extension CategorySettingImageMock {
    static var mock: [Self] = [
        Self(
            imageId: 0,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 1,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 2,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 3,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 4,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 5,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 6,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 7,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 8,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 9,
            imageUrl: Constants.mockImageUrl
        ),
        Self(
            imageId: 10,
            imageUrl: Constants.mockImageUrl
        ),
    ]
}


public struct CategoryItemMock: Identifiable, Equatable {
    public let id: Int
    let userId: Int
    let categoryName: String
    let categoryImage: CategorySettingImageMock
    let linkCount: Int
}

extension CategoryItemMock {
    public static var mock: [Self] =
    [
        Self(
            id: 0,
            userId: 1,
            categoryName: "카테고리명",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 14
        ),
        Self(
            id: 1,
            userId: 1,
            categoryName: "여행",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 0
        ),
        Self(
            id: 2,
            userId: 1,
            categoryName: "맛집리스트",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 2
        ),
        Self(
            id: 3,
            userId: 1,
            categoryName: "디자인 레퍼런스",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 7
        ),
        Self(
            id: 4,
            userId: 1,
            categoryName: "프로그래밍",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 3
        ),
        Self(
            id: 5,
            userId: 1,
            categoryName: "백종원의 달콤살벌 홍콩반점",
            categoryImage: CategorySettingImageMock(
            imageId: 0,
            imageUrl: "hi"
            ),
            linkCount: 182
        ),
    ]
}

/*
 {
 "categoryId": 0,
 "categoryName": "string",
 "categoryImage": {
 "imageId": 0,
 "imageUrl": "string"
 }
 }
 */
