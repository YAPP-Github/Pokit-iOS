import Foundation

import CoreKit
import Domain
import Util

private func featureContentDetailDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseCategoryResponse {
    static let featureContentDetail_pokit: Self = featureContentDetailDecode([
        "categoryId": 12,
        "categoryName": "개발 레퍼런스"
    ])
}

extension BaseCategoryInfo {
    static let featureContentDetail_pokit = Self(
        categoryId: 12,
        categoryName: "개발 레퍼런스"
    )
}

extension BaseCategoryItem {
    static let featureContentDetail_unclassified = Self(
        id: 0,
        userId: 100,
        categoryName: Constants.미분류,
        categoryImage: .init(imageId: 10, imageURL: Constants.mockImageUrl),
        contentCount: 2,
        createdAt: "2026.04.06",
        openType: .비공개,
        keywordType: .default,
        userCount: 1,
        isFavorite: false
    )

    static let featureContentDetail_pokit = Self(
        id: 12,
        userId: 100,
        categoryName: "개발 레퍼런스",
        categoryImage: .init(imageId: 11, imageURL: Constants.mockImageUrl),
        contentCount: 4,
        createdAt: "2026.04.06",
        openType: .공개,
        keywordType: .IT,
        userCount: 2,
        isFavorite: false
    )
}

extension BaseContentDetail {
    static let featureContentDetail_owned = Self(
        id: 301,
        category: .featureContentDetail_pokit,
        title: "내가 저장한 링크",
        data: "https://pokit.link/mine",
        memo: "내 메모",
        createdAt: "2026.04.06",
        favorites: false,
        alertYn: .no,
        authorUserId: 100,
        authorNickname: "나",
        authorProfileImageURL: "https://example.com/me.png"
    )

    static let featureContentDetail_shared = Self(
        id: 302,
        category: .featureContentDetail_pokit,
        title: "다른 사람이 저장한 링크",
        data: "https://pokit.link/shared",
        memo: "공유 메모",
        createdAt: "2026.04.06",
        favorites: false,
        alertYn: .no,
        authorUserId: 999,
        authorNickname: "공유멤버",
        authorProfileImageURL: "https://example.com/shared.png"
    )
}

extension BaseReportReason {
    static let featureContentDetail_spam = Self(code: "SPAM", description: "스팸 또는 혼돈을 야기하는 링크")
    static let featureContentDetail_harmful = Self(code: "HARMFUL", description: "유해하거나 위험한 링크")
}

extension CategoryListInquiryResponse {
    static let featureContentDetail_categoryListResponse: Self = featureContentDetailDecode([
        "data": [
            [
                "categoryId": 12,
                "userId": 100,
                "categoryName": "개발 레퍼런스",
                "categoryImage": [
                    "imageId": 11,
                    "imageUrl": Constants.mockImageUrl
                ],
                "contentCount": 4,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PUBLIC",
                "keywordType": "IT",
                "userCount": 2,
                "isFavorite": false,
                "alertEnabled": true
            ],
            [
                "categoryId": 0,
                "userId": 100,
                "categoryName": Constants.미분류,
                "categoryImage": [
                    "imageId": 10,
                    "imageUrl": Constants.mockImageUrl
                ],
                "contentCount": 2,
                "createdAt": "2026-04-06T00:00:00Z",
                "openType": "PRIVATE",
                "keywordType": "default",
                "userCount": 1,
                "isFavorite": false,
                "alertEnabled": true
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
    static let featureContentDetail_sortedPokits: Self = {
        var list = CategoryListInquiryResponse.featureContentDetail_categoryListResponse.toDomain().data ?? []
        guard let unclassifiedIndex = list.firstIndex(where: { $0.categoryName == Constants.미분류 }) else {
            return list
        }
        let unclassifiedItem = list.remove(at: unclassifiedIndex)
        list.insert(unclassifiedItem, at: 0)
        return list
    }()
}

extension ContentDetailResponse {
    static let featureContentDetail_ownedResponse = Self(
        contentId: 301,
        category: .featureContentDetail_pokit,
        data: "https://pokit.link/mine",
        title: "내가 저장한 링크",
        memo: "내 메모",
        alertYn: "NO",
        createdAt: "2026-04-06T00:00:00Z",
        favorites: false,
        keyword: nil,
        userNickname: "나",
        authorUserId: 100,
        authorNickname: "나",
        authorProfileImageURL: "https://example.com/me.png"
    )

    static let featureContentDetail_sharedResponse = Self(
        contentId: 302,
        category: .featureContentDetail_pokit,
        data: "https://pokit.link/shared",
        title: "다른 사람이 저장한 링크",
        memo: "공유 메모",
        alertYn: "NO",
        createdAt: "2026-04-06T00:00:00Z",
        favorites: false,
        keyword: nil,
        userNickname: "공유멤버",
        authorUserId: 999,
        authorNickname: "공유멤버",
        authorProfileImageURL: "https://example.com/shared.png"
    )
}

extension ReportReasonResponse {
    static let featureContentDetail_spam: Self = featureContentDetailDecode([
        "code": "SPAM",
        "description": "스팸 또는 혼돈을 야기하는 링크"
    ])
    static let featureContentDetail_harmful: Self = featureContentDetailDecode([
        "code": "HARMFUL",
        "description": "유해하거나 위험한 링크"
    ])
}

extension ContentClient {
    static func featureContentDetailTestValue(
        detailResponse: ContentDetailResponse = .featureContentDetail_sharedResponse,
        reportReasons: [ReportReasonResponse] = [
            .featureContentDetail_spam,
            .featureContentDetail_harmful
        ],
        onReport: (@Sendable (Int, ContentReportRequest) async throws -> Void)? = nil,
        onAdd: (@Sendable (ContentBaseRequest) async throws -> ContentDetailResponse)? = nil,
        onEdit: (@Sendable (String, ContentBaseRequest) async throws -> ContentDetailResponse)? = nil
    ) -> Self {
        var client = Self.testValue
        client.컨텐츠_상세_조회 = { _ in detailResponse }
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
            return .featureContentDetail_sharedResponse
        }
        client.컨텐츠_수정 = { contentId, request in
            if let onEdit {
                return try await onEdit(contentId, request)
            }
            return .featureContentDetail_ownedResponse
        }
        return client
    }
}

extension CategoryClient {
    static func featureContentDetailTestValue(
        categoryListResponse: CategoryListInquiryResponse = .featureContentDetail_categoryListResponse
    ) -> Self {
        var client = Self.testValue
        client.카테고리_목록_조회 = { _, _, _ in categoryListResponse }
        return client
    }
}

extension UserDefaultsClient {
    static func featureContentDetailTestValue(currentUserId: Int?) -> Self {
        var client = Self.testValue
        client.stringKey = { key in
            switch key {
            case .userId:
                return currentUserId.map(String.init)
            default:
                return nil
            }
        }
        return client
    }
}

extension SwiftSoupClient {
    static func featureContentDetailTestValue(
        imageURL: String = "https://example.com/saved-thumbnail.png"
    ) -> Self {
        var client = Self.testValue
        client.parseOGImageURL = { _ in imageURL }
        return client
    }
}
