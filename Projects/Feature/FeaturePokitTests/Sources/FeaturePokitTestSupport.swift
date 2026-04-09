import Foundation

import CoreKit
import Domain
import Util

private let featurePokitMockImageUrl = "https://picsum.photos/200"

private func featurePokitDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseCategoryItem {
    static let featurePokit_favoriteCategory = Self(
        id: 900,
        userId: 100,
        categoryName: "즐겨찾기",
        categoryImage: .init(imageId: 900, imageURL: featurePokitMockImageUrl),
        contentCount: 0,
        createdAt: "2026-04-06T00:00:00Z",
        openType: .비공개,
        keywordType: .default,
        userCount: 1,
        isFavorite: true
    )

    static let featurePokit_sharedCategory = Self(
        id: 901,
        userId: 100,
        categoryName: "공유 포킷",
        categoryImage: .init(imageId: 901, imageURL: featurePokitMockImageUrl),
        contentCount: 4,
        createdAt: "2026-04-06T00:00:00Z",
        openType: .공개,
        keywordType: .IT,
        userCount: 3,
        isFavorite: false
    )

    static let featurePokit_privateShared = Self(
        id: 903,
        userId: 100,
        categoryName: "비공개 공유",
        categoryImage: .init(imageId: 903, imageURL: featurePokitMockImageUrl),
        contentCount: 2,
        createdAt: "2026.04.06",
        openType: .비공개,
        keywordType: .IT,
        userCount: 2,
        isFavorite: false
    )

    static let featurePokit_privateSolo = Self(
        id: 904,
        userId: 100,
        categoryName: "비공개 개인",
        categoryImage: .init(imageId: 904, imageURL: featurePokitMockImageUrl),
        contentCount: 3,
        createdAt: "2026.04.05",
        openType: .비공개,
        keywordType: .default,
        userCount: 1,
        isFavorite: false
    )

    static let featurePokit_publicShared = Self(
        id: 905,
        userId: 100,
        categoryName: "전체공개 공유",
        categoryImage: .init(imageId: 905, imageURL: featurePokitMockImageUrl),
        contentCount: 4,
        createdAt: "2026.04.04",
        openType: .공개,
        keywordType: .IT,
        userCount: 3,
        isFavorite: false
    )

    static let featurePokit_publicSolo = Self(
        id: 906,
        userId: 100,
        categoryName: "전체공개 개인",
        categoryImage: .init(imageId: 906, imageURL: featurePokitMockImageUrl),
        contentCount: 1,
        createdAt: "2026.04.03",
        openType: .공개,
        keywordType: .default,
        userCount: 1,
        isFavorite: false
    )
}

extension BaseContentItem {
    static let featurePokit_unclassifiedContent = Self(
        id: 902,
        categoryName: Constants.미분류,
        categoryId: 0,
        title: "미분류 링크",
        memo: nil,
        thumbNail: featurePokitMockImageUrl,
        data: "https://pokit.link/unclassified",
        domain: "pokit.link",
        createdAt: "2026.04.06",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: nil,
        authorNickname: nil,
        authorProfileImageURL: nil
    )
}

extension CategoryListInquiryResponse {
    static let featurePokit_categoryListResponse: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 900,
                "userId": 100,
                "categoryName": "즐겨찾기",
                "categoryImage": [
                    "imageId": 900,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 0,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": true
            ],
            [
                "categoryId": 901,
                "userId": 100,
                "categoryName": "공유 포킷",
                "categoryImage": [
                    "imageId": 901,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 4,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "IT",
                "userCount": 2,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])

    static let featurePokit_qaCategoryListResponse: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 900,
                "userId": 100,
                "categoryName": "즐겨찾기",
                "categoryImage": [
                    "imageId": 900,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 0,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": true
            ],
            [
                "categoryId": 903,
                "userId": 100,
                "categoryName": "비공개 공유",
                "categoryImage": [
                    "imageId": 903,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 2,
                "createdAt": "2026-04-05T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "IT",
                "userCount": 1,
                "isFavorite": false
            ],
            [
                "categoryId": 904,
                "userId": 100,
                "categoryName": "비공개 개인",
                "categoryImage": [
                    "imageId": 904,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 3,
                "createdAt": "2026-04-04T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": false
            ],
            [
                "categoryId": 905,
                "userId": 100,
                "categoryName": "전체공개 공유",
                "categoryImage": [
                    "imageId": 905,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 4,
                "createdAt": "2026-04-03T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "IT",
                "userCount": 2,
                "isFavorite": false
            ],
            [
                "categoryId": 906,
                "userId": 100,
                "categoryName": "전체공개 개인",
                "categoryImage": [
                    "imageId": 906,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 1,
                "createdAt": "2026-04-02T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])
}

extension ContentListInquiryResponse {
    static let featurePokit_unclassifiedListResponse: Self = featurePokitDecode([
        "data": [[
            "contentId": 902,
            "category": [
                "categoryId": 0,
                "categoryName": Constants.미분류
            ],
            "data": "https://pokit.link/unclassified",
            "domain": "pokit.link",
            "title": "미분류 링크",
            "memo": NSNull(),
            "thumbNail": featurePokitMockImageUrl,
            "createdAt": "2026.04.06",
            "isRead": false,
            "isFavorite": false,
            "keyword": NSNull()
        ]],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])
}

// MARK: - TC-01: 즐겨찾기만 있는 응답 (컨텐츠 0개)
extension CategoryListInquiryResponse {
    static let featurePokit_favoriteOnlyResponse: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 900,
                "userId": 100,
                "categoryName": "즐겨찾기",
                "categoryImage": [
                    "imageId": 900,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 0,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": true
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])

    // MARK: - TC-02: 비공개 + 공동편집자 있음
    static let featurePokit_tc02Response: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 903,
                "userId": 100,
                "categoryName": "비공개 공유",
                "categoryImage": [
                    "imageId": 903,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 2,
                "createdAt": "2026-04-05T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "IT",
                "userCount": 1,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])

    // MARK: - TC-03: 비공개 + 공동편집자 없음
    static let featurePokit_tc03Response: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 904,
                "userId": 100,
                "categoryName": "비공개 개인",
                "categoryImage": [
                    "imageId": 904,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 3,
                "createdAt": "2026-04-04T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])

    // MARK: - TC-04: 전체공개 + 공동편집자 있음
    static let featurePokit_tc04Response: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 905,
                "userId": 100,
                "categoryName": "전체공개 공유",
                "categoryImage": [
                    "imageId": 905,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 4,
                "createdAt": "2026-04-03T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "IT",
                "userCount": 2,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])

    // MARK: - TC-05: 전체공개 + 공동편집자 없음
    static let featurePokit_tc05Response: Self = featurePokitDecode([
        "data": [
            [
                "categoryId": 906,
                "userId": 100,
                "categoryName": "전체공개 개인",
                "categoryImage": [
                    "imageId": 906,
                    "imageUrl": featurePokitMockImageUrl
                ],
                "contentCount": 1,
                "createdAt": "2026-04-02T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "default",
                "userCount": 0,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 10,
        "sort": [[
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]],
        "hasNext": false
    ])
}

extension CategoryClient {
    static func featurePokitTestValue(
        categoryListResponse: CategoryListInquiryResponse = .featurePokit_categoryListResponse
    ) -> Self {
        var client = Self.testValue
        client.카테고리_목록_조회 = { _, _, _ in categoryListResponse }
        return client
    }
}

extension ContentClient {
    static func featurePokitTestValue(
        unclassifiedResponse: ContentListInquiryResponse = .featurePokit_unclassifiedListResponse
    ) -> Self {
        var client = Self.testValue
        client.미분류_카테고리_컨텐츠_조회 = { _ in unclassifiedResponse }
        return client
    }
}
