import Foundation

import CoreKit
import Domain
import Util

private func featureRecommendDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseCategoryResponse {
    static let featureRecommend_category: Self = featureRecommendDecode([
        "categoryId": 21,
        "categoryName": "저장 포킷"
    ])
}

extension ContentBaseRequest {
    var featureRecommend_categoryId: Int {
        guard let categoryId = Mirror(reflecting: self).descendant("categoryId") as? Int else {
            preconditionFailure("ContentBaseRequest.categoryId 추출에 실패했습니다.")
        }
        return categoryId
    }
}

extension BaseInterest {
    static let featureRecommend_it = InterestResponse(code: "it", description: "IT").toDomian()
    static let featureRecommend_design = InterestResponse(code: "design", description: "디자인").toDomian()
    static let featureRecommend_place = InterestResponse(code: "place", description: "장소").toDomian()
    static let featureRecommend_travel = InterestResponse(code: "travel", description: "여행").toDomian()
}

extension Array where Element == BaseInterest {
    static let featureRecommend_availableInterests: Self = [
        .featureRecommend_it,
        .featureRecommend_design,
        .featureRecommend_place,
        .featureRecommend_travel
    ].sorted { $0.description < $1.description }

    static let featureRecommend_myInterests: Self = [
        .featureRecommend_it,
        .featureRecommend_design
    ]
}

extension BaseReportReason {
    static let featureRecommend_spam = Self(code: "SPAM", description: "스팸 또는 혼돈을 야기하는 링크")
    static let featureRecommend_violent = Self(code: "VIOLENT", description: "폭력적 또는 혐오스러운 링크")
}

extension BaseContentItem {
    static let featureRecommend_first = Self(
        id: 401,
        categoryName: "추천",
        categoryId: 1,
        title: "추천 링크 1",
        memo: "추천 링크 메모 1",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/recommend-1",
        domain: "pokit.link",
        createdAt: "2026.04.06",
        isRead: false,
        isFavorite: false,
        keyword: "IT",
        authorUserId: 31,
        authorNickname: "추천유저1",
        authorProfileImageURL: "https://example.com/recommend-1.png"
    )

    static let featureRecommend_second = Self(
        id: 402,
        categoryName: "추천",
        categoryId: 1,
        title: "추천 링크 2",
        memo: "추천 링크 메모 2",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/recommend-2",
        domain: "pokit.link",
        createdAt: "2026.04.05",
        isRead: false,
        isFavorite: false,
        keyword: "디자인",
        authorUserId: 32,
        authorNickname: "추천유저2",
        authorProfileImageURL: "https://example.com/recommend-2.png"
    )
}

extension BaseCategoryItem {
    static let featureRecommend_unclassified = Self(
        id: 0,
        userId: 100,
        categoryName: Constants.미분류,
        categoryImage: .init(imageId: 20, imageURL: Constants.mockImageUrl),
        contentCount: 2,
        createdAt: "2026.04.06",
        openType: .비공개,
        keywordType: .default,
        userCount: 1,
        isFavorite: false
    )

    static let featureRecommend_category = Self(
        id: 21,
        userId: 100,
        categoryName: "저장 포킷",
        categoryImage: .init(imageId: 21, imageURL: Constants.mockImageUrl),
        contentCount: 5,
        createdAt: "2026.04.06",
        openType: .공개,
        keywordType: .IT,
        userCount: 1,
        isFavorite: false
    )
}

extension ContentListInquiryResponse {
    static let featureRecommend_pageResponse: Self = featureRecommendDecode([
        "data": [
            [
                "contentId": 401,
                "category": [
                    "categoryId": 1,
                    "categoryName": "추천"
                ],
                "data": "https://pokit.link/recommend-1",
                "domain": "pokit.link",
                "title": "추천 링크 1",
                "memo": "추천 링크 메모 1",
                "thumbNail": Constants.mockImageUrl,
                "createdAt": "2026.04.06",
                "isRead": false,
                "isFavorite": false,
                "keyword": "IT",
                "author": [
                    "userId": 31,
                    "nickname": "추천유저1",
                    "profileImageUrl": "https://example.com/recommend-1.png"
                ]
            ],
            [
                "contentId": 402,
                "category": [
                    "categoryId": 1,
                    "categoryName": "추천"
                ],
                "data": "https://pokit.link/recommend-2",
                "domain": "pokit.link",
                "title": "추천 링크 2",
                "memo": "추천 링크 메모 2",
                "thumbNail": Constants.mockImageUrl,
                "createdAt": "2026.04.05",
                "isRead": false,
                "isFavorite": false,
                "keyword": "디자인",
                "author": [
                    "userId": 32,
                    "nickname": "추천유저2",
                    "profileImageUrl": "https://example.com/recommend-2.png"
                ]
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

extension CategoryListInquiryResponse {
    static let featureRecommend_categoryListResponse: Self = featureRecommendDecode([
        "data": [
            [
                "categoryId": 21,
                "userId": 100,
                "categoryName": "저장 포킷",
                "categoryImage": [
                    "imageId": 21,
                    "imageUrl": Constants.mockImageUrl
                ],
                "contentCount": 5,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "IT",
                "userCount": 1,
                "isFavorite": false
            ],
            [
                "categoryId": 0,
                "userId": 100,
                "categoryName": Constants.미분류,
                "categoryImage": [
                    "imageId": 20,
                    "imageUrl": Constants.mockImageUrl
                ],
                "contentCount": 2,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 1,
                "isFavorite": false
            ]
        ],
        "page": 0,
        "size": 30,
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

extension Array where Element == BaseCategoryItem {
    static let featureRecommend_sortedPokits: Self = {
        var list = CategoryListInquiryResponse.featureRecommend_categoryListResponse.toDomain().data ?? []
        guard let unclassifiedIndex = list.firstIndex(where: { $0.categoryName == Constants.미분류 }) else {
            return list
        }
        let unclassifiedItem = list.remove(at: unclassifiedIndex)
        list.insert(unclassifiedItem, at: 0)
        return list
    }()
}

extension ReportReasonResponse {
    static let featureRecommend_spam: Self = featureRecommendDecode([
        "code": "SPAM",
        "description": "스팸 또는 혼돈을 야기하는 링크"
    ])
    static let featureRecommend_violent: Self = featureRecommendDecode([
        "code": "VIOLENT",
        "description": "폭력적 또는 혐오스러운 링크"
    ])
}

extension ContentDetailResponse {
    static let featureRecommend_addResponse = Self(
        contentId: 999,
        category: .featureRecommend_category,
        data: "https://pokit.link/recommend-added",
        title: "저장된 추천 링크",
        memo: "저장된 추천 링크",
        alertYn: "NO",
        createdAt: "2026-04-06T00:00:00Z",
        favorites: false,
        keyword: nil,
        userNickname: "나",
        authorUserId: 100,
        authorNickname: "나",
        authorProfileImageURL: nil
    )
}

extension ContentClient {
    static func featureRecommendTestValue(
        listResponse: ContentListInquiryResponse = .featureRecommend_pageResponse,
        reportReasons: [ReportReasonResponse] = [
            .featureRecommend_spam,
            .featureRecommend_violent
        ],
        onReport: (@Sendable (Int, ContentReportRequest) async throws -> Void)? = nil,
        onAdd: (@Sendable (ContentBaseRequest) async throws -> ContentDetailResponse)? = nil
    ) -> Self {
        var client = Self.testValue
        client.추천_컨텐츠_조회 = { _, _ in listResponse }
        client.컨텐츠_신고사유_조회 = { reportReasons }
        client.컨텐츠_신고_사유 = { id, request in
            if let onReport {
                try await onReport(id, request)
            }
        }
        client.컨텐츠_추가 = { request in
            if let onAdd {
                return try await onAdd(request)
            }
            return .featureRecommend_addResponse
        }
        return client
    }
}

extension CategoryClient {
    static func featureRecommendTestValue(
        categoryListResponse: CategoryListInquiryResponse = .featureRecommend_categoryListResponse
    ) -> Self {
        var client = Self.testValue
        client.카테고리_목록_조회 = { _, _, _ in categoryListResponse }
        return client
    }
}

extension UserClient {
    static func featureRecommendTestValue(
        interests: [InterestResponse] = [
            .init(code: "default", description: "기본"),
            .init(code: "it", description: "IT"),
            .init(code: "design", description: "디자인"),
            .init(code: "place", description: "장소"),
            .init(code: "travel", description: "여행")
        ],
        myInterests: [InterestResponse] = [
            .init(code: "it", description: "IT"),
            .init(code: "design", description: "디자인")
        ],
        onInterestUpdate: (@Sendable (InterestRequest) async throws -> Void)? = nil
    ) -> Self {
        var client = Self.testValue
        client.관심사_목록_조회 = { interests }
        client.유저_관심사_목록_조회 = { myInterests }
        client.관심사_수정 = { request in
            if let onInterestUpdate {
                try await onInterestUpdate(request)
            }
        }
        return client
    }
}
