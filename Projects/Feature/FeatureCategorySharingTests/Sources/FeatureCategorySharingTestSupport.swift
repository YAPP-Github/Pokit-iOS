import Foundation

import CoreKit
import Domain
import FeatureContentCard

private func featureCategorySharingDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseContentItem {
    static let featureCategorySharing_first = Self(
        id: 701,
        categoryName: "공유 포킷",
        categoryId: 55,
        title: "공유 링크 1",
        memo: "메모 1",
        thumbNail: "https://example.com/thumb-1.png",
        data: "https://pokit.link/shared-1",
        domain: "pokit.link",
        createdAt: "2026-04-06T00:00:00Z",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: 91,
        authorNickname: "공유멤버1",
        authorProfileImageURL: "https://example.com/author-1.png"
    )

    static let featureCategorySharing_second = Self(
        id: 702,
        categoryName: "공유 포킷",
        categoryId: 55,
        title: "공유 링크 2",
        memo: "메모 2",
        thumbNail: "https://example.com/thumb-2.png",
        data: "https://pokit.link/shared-2",
        domain: "pokit.link",
        createdAt: "2026-04-05T00:00:00Z",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: 92,
        authorNickname: "공유멤버2",
        authorProfileImageURL: "https://example.com/author-2.png"
    )

    static let featureCategorySharing_third = Self(
        id: 703,
        categoryName: "공유 포킷",
        categoryId: 55,
        title: "공유 링크 3",
        memo: "메모 3",
        thumbNail: "https://example.com/thumb-3.png",
        data: "https://pokit.link/shared-3",
        domain: "pokit.link",
        createdAt: "2026-04-04T00:00:00Z",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: 93,
        authorNickname: "공유멤버3",
        authorProfileImageURL: "https://example.com/author-3.png"
    )
}

extension ContentCardFeature.State {
    static let featureCategorySharing_firstCard = Self(content: .featureCategorySharing_first)
    static let featureCategorySharing_secondCard = Self(content: .featureCategorySharing_second)
    static let featureCategorySharing_thirdCard = Self(content: .featureCategorySharing_third)
}

extension SharedCategoryResponse {
    static let featureCategorySharing_initialResponse: Self = featureCategorySharingDecode([
        "category": [
            "categoryId": 55,
            "categoryName": "공유 포킷",
            "contentCount": 2,
            "categoryImageId": 501,
            "categoryImageUrl": "https://example.com/shared-category.png"
        ],
        "contents": [
            "data": [
                [
                    "contentId": 701,
                    "data": "https://pokit.link/shared-1",
                    "domain": "pokit.link",
                    "title": "공유 링크 1",
                    "memo": "메모 1",
                    "thumbNail": "https://example.com/thumb-1.png",
                    "createdAt": "2026-04-06T00:00:00Z",
                    "author": [
                        "userId": 91,
                        "nickname": "공유멤버1",
                        "profileImageUrl": "https://example.com/author-1.png"
                    ]
                ],
                [
                    "contentId": 702,
                    "data": "https://pokit.link/shared-2",
                    "domain": "pokit.link",
                    "title": "공유 링크 2",
                    "memo": "메모 2",
                    "thumbNail": "https://example.com/thumb-2.png",
                    "createdAt": "2026-04-05T00:00:00Z",
                    "author": [
                        "userId": 92,
                        "nickname": "공유멤버2",
                        "profileImageUrl": "https://example.com/author-2.png"
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
            "hasNext": true
        ]
    ])

    static let featureCategorySharing_nextPageResponse: Self = featureCategorySharingDecode([
        "category": [
            "categoryId": 55,
            "categoryName": "공유 포킷",
            "contentCount": 3,
            "categoryImageId": 501,
            "categoryImageUrl": "https://example.com/shared-category.png"
        ],
        "contents": [
            "data": [[
                "contentId": 703,
                "data": "https://pokit.link/shared-3",
                "domain": "pokit.link",
                "title": "공유 링크 3",
                "memo": "메모 3",
                "thumbNail": "https://example.com/thumb-3.png",
                "createdAt": "2026-04-04T00:00:00Z",
                "author": [
                    "userId": 93,
                    "nickname": "공유멤버3",
                    "profileImageUrl": "https://example.com/author-3.png"
                ]
            ]],
            "page": 1,
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

// MARK: - TC-15: 초대 수락 시나리오 mock

extension BaseContentItem {
    static let featureCategorySharing_invite = Self(
        id: 710,
        categoryName: "초대 포킷",
        categoryId: 60,
        title: "초대 링크 1",
        memo: "초대 메모",
        thumbNail: "https://example.com/thumb-invite.png",
        data: "https://pokit.link/invite-1",
        domain: "pokit.link",
        createdAt: "2026-04-07T00:00:00Z",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: 95,
        authorNickname: "초대자",
        authorProfileImageURL: "https://example.com/author-invite.png"
    )
}

extension ContentCardFeature.State {
    static let featureCategorySharing_inviteCard = Self(
        content: .featureCategorySharing_invite
    )
}

extension SharedCategoryResponse {
    // TC-15: 초대 수락 응답
    static let featureCategorySharing_inviteResponse: Self = featureCategorySharingDecode([
        "category": [
            "categoryId": 60,
            "categoryName": "초대 포킷",
            "contentCount": 1,
            "categoryImageId": 510,
            "categoryImageUrl": "https://example.com/invite-category.png"
        ],
        "contents": [
            "data": [
                [
                    "contentId": 710,
                    "data": "https://pokit.link/invite-1",
                    "domain": "pokit.link",
                    "title": "초대 링크 1",
                    "memo": "초대 메모",
                    "thumbNail": "https://example.com/thumb-invite.png",
                    "createdAt": "2026-04-07T00:00:00Z",
                    "author": [
                        "userId": 95,
                        "nickname": "초대자",
                        "profileImageUrl": "https://example.com/author-invite.png"
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
        ]
    ])

    // TC-17: 마지막 참여자 응답 (컨텐츠 0개)
    static let featureCategorySharing_lastParticipantResponse: Self = featureCategorySharingDecode([
        "category": [
            "categoryId": 70,
            "categoryName": "나가기 포킷",
            "contentCount": 0,
            "categoryImageId": 520,
            "categoryImageUrl": "https://example.com/leave-category.png"
        ],
        "contents": [
            "data": [] as [[String: Any]],
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

extension CategoryClient {
    static func featureCategorySharingTestValue(
        sharedResponse: SharedCategoryResponse = .featureCategorySharing_nextPageResponse
    ) -> Self {
        var client = Self.testValue
        client.공유받은_카테고리_조회 = { _, _ in sharedResponse }
        return client
    }
}
