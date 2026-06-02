import Foundation

import CoreKit
import Domain
import FeatureContentCard
import Util

private func featureCategoryDetailDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseCategoryItem {
    static let featureCategoryDetail_sharedCategory = Self(
        id: 55,
        userId: 100,
        categoryName: "공유 포킷",
        categoryImage: .init(imageId: 501, imageURL: Constants.mockImageUrl),
        contentCount: 3,
        createdAt: "2026.04.06",
        openType: .공개,
        keywordType: .IT,
        userCount: 3,
        isFavorite: false
    )
}

extension BaseContentItem {
    static let featureCategoryDetail_sharedContent = Self(
        id: 801,
        categoryName: "공유 포킷",
        categoryId: 55,
        title: "공유 링크",
        memo: "공유 메모",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/category-detail",
        domain: "pokit.link",
        createdAt: "2026.04.06",
        isRead: false,
        isFavorite: true,
        keyword: nil,
        authorUserId: 201,
        authorNickname: "참여멤버",
        authorProfileImageURL: "https://example.com/category-detail-author.png"
    )

    static let featureCategoryDetail_participantPersonalizedContent = Self(
        id: 802,
        categoryName: "공유 포킷",
        categoryId: 55,
        title: "개인화 링크",
        memo: "참여자 개인 메모",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/personalized",
        domain: "pokit.link",
        createdAt: "2026.04.05",
        isRead: true,
        isFavorite: true,
        keyword: nil,
        authorUserId: 202,
        authorNickname: "최근참여자",
        authorProfileImageURL: "https://example.com/category-detail-latest.png"
    )
}

extension ContentCardFeature.State {
    static let featureCategoryDetail_sharedCard = Self(content: .featureCategoryDetail_sharedContent)
}

extension SharedCategoryResponse {
    static let featureCategoryDetail_sharedResponse: Self = featureCategoryDetailDecode([
        "category": [
            "categoryId": 55,
            "categoryName": "공유 포킷",
            "contentCount": 1,
            "categoryImageId": 501,
            "categoryImageUrl": Constants.mockImageUrl
        ],
        "contents": [
            "data": [[
                "contentId": 801,
                "data": "https://pokit.link/category-detail",
                "domain": "pokit.link",
                "title": "공유 링크",
                "memo": "공유 메모",
                "thumbNail": Constants.mockImageUrl,
                "createdAt": "2026-04-06T00:00:00Z",
                "author": [
                    "userId": 201,
                    "nickname": "참여멤버",
                    "profileImageUrl": "https://example.com/category-detail-author.png"
                ]
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
        ]
    ])
}

extension InvitedUserResponse {
    static let featureCategoryDetail_owner: Self = featureCategoryDetailDecode([
        "userId": 100,
        "nickname": "방장",
        "profileImage": [
            "id": 1,
            "url": "https://example.com/owner.png"
        ]
    ])

    static let featureCategoryDetail_member: Self = featureCategoryDetailDecode([
        "userId": 201,
        "nickname": "참여멤버",
        "profileImage": [
            "id": 2,
            "url": "https://example.com/member.png"
        ]
    ])

    static let featureCategoryDetail_latestMember: Self = featureCategoryDetailDecode([
        "userId": 202,
        "nickname": "최근참여자",
        "profileImage": [
            "id": 3,
            "url": "https://example.com/latest-member.png"
        ]
    ])
}

extension Array where Element == InvitedUserResponse {
    static let featureCategoryDetail_latestOrder: Self = [
        .featureCategoryDetail_latestMember,
        .featureCategoryDetail_owner,
        .featureCategoryDetail_member
    ]

    static let featureCategoryDetail_ownerOnly: Self = [
        .featureCategoryDetail_owner
    ]
}

extension ContentListInquiryResponse {
    static let featureCategoryDetail_participantListResponse: Self = featureCategoryDetailDecode([
        "data": [[
            "contentId": 802,
            "category": [
                "categoryId": 55,
                "categoryName": "공유 포킷"
            ],
            "data": "https://pokit.link/personalized",
            "domain": "pokit.link",
            "title": "개인화 링크",
            "memo": "참여자 개인 메모",
            "thumbNail": Constants.mockImageUrl,
            "createdAt": "2026.04.05",
            "isRead": true,
            "isFavorite": true,
            "keyword": NSNull(),
            "author": [
                "userId": 202,
                "nickname": "최근참여자",
                "profileImageUrl": "https://example.com/category-detail-latest.png"
            ]
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

extension CategoryClient {
    static func featureCategoryDetailTestValue(
        sharedResponse: SharedCategoryResponse = .featureCategoryDetail_sharedResponse,
        invitedUsers: [InvitedUserResponse] = [
            .featureCategoryDetail_owner,
            .featureCategoryDetail_member
        ],
        onAcceptInvite: (@Sendable (Int) async throws -> Void)? = nil,
        onSaveShared: (@Sendable (CopiedCategoryRequest) async throws -> Void)? = nil,
        onRemoveParticipant: (@Sendable (Int, Int) async throws -> Void)? = nil,
        onLeave: (@Sendable (Int) async throws -> Void)? = nil
    ) -> Self {
        var client = Self.testValue
        client.공유받은_카테고리_조회 = { _, _ in sharedResponse }
        client.포킷_초대된_유저_목록_조회 = { _ in invitedUsers }
        client.포킷_초대_수락 = { id in
            if let onAcceptInvite {
                try await onAcceptInvite(id)
            }
        }
        client.공유받은_카테고리_저장 = { request in
            if let onSaveShared {
                try await onSaveShared(request)
            }
        }
        client.포킷_내보내기 = { categoryId, userId in
            if let onRemoveParticipant {
                try await onRemoveParticipant(categoryId, userId)
            }
        }
        client.포킷_나가기 = { categoryId in
            if let onLeave {
                try await onLeave(categoryId)
            }
        }
        return client
    }
}

extension ContentClient {
    static func featureCategoryDetailTestValue(
        participantListResponse: ContentListInquiryResponse = .featureCategoryDetail_participantListResponse
    ) -> Self {
        var client = Self.testValue
        client.카테고리_내_컨텐츠_목록_조회 = { _, _, _ in participantListResponse }
        return client
    }
}

extension UserDefaultsClient {
    static func featureCategoryDetailTestValue(currentUserId: Int?) -> Self {
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
