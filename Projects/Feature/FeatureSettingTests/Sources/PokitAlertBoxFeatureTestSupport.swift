import Foundation

import CoreKit
import Domain
import Util

let featureSetting_defaultSort: [BaseItemInquirySort] = [
    BaseItemInquirySort(
        direction: "DESC",
        nullHandling: "NATIVE",
        ascending: false,
        property: "createdAt",
        ignoreCase: false
    )
]

private func featureSettingDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension NotificationItem {
    static let featureSetting_unread = Self(
        id: 1,
        notificationType: "LINK_ADDED",
        title: "'공유 포킷'에 링크가 추가되었어요",
        body: "멤버가 추가한 링크를 확인해보세요",
        categoryImageUrl: "https://example.com/category.png",
        isRead: false,
        navigationType: "CONTENT_DETAIL",
        deepLink: "pokit://shared?categoryId=10&contentId=2",
        createdAt: "2026-04-06T00:00:00Z"
    )

    static let featureSetting_read = Self(
        id: 2,
        notificationType: "MEMBER_JOINED",
        title: "새로운 멤버가 참여했어요",
        body: "새 멤버를 확인해보세요",
        categoryImageUrl: "https://example.com/category-2.png",
        isRead: true,
        navigationType: "USER_LIST",
        deepLink: "pokit://shared?categoryId=10&userId=3",
        createdAt: "2026-04-05T00:00:00Z"
    )

    static let featureSetting_pagination = Self(
        id: 3,
        notificationType: "RESTRICTED",
        title: "'공유 포킷' 포킷 사용이 제한되었어요",
        body: "내보내기 처리된 포킷을 확인해보세요",
        categoryImageUrl: "https://example.com/category-3.png",
        isRead: false,
        navigationType: "ALERT_BOX",
        deepLink: "pokit://alert",
        createdAt: "2026-04-04T00:00:00Z"
    )

    /// TC-35: CONTENT_DETAIL 딥링크 알림
    static let featureSetting_contentDetailDeeplink = Self(
        id: 10,
        notificationType: "LINK_ADDED",
        title: "'개발 포킷'에 링크가 추가되었어요",
        body: "새 링크를 확인해보세요",
        categoryImageUrl: "https://example.com/category-dev.png",
        isRead: false,
        navigationType: "CONTENT_DETAIL",
        deepLink: "pokit://content-detail?contentId=99",
        createdAt: "2026-04-06T12:00:00Z"
    )

    /// TC-35: USER_LIST 딥링크 알림
    static let featureSetting_userListDeeplink = Self(
        id: 11,
        notificationType: "MEMBER_JOINED",
        title: "새로운 멤버가 참여했어요",
        body: "멤버 목록을 확인해보세요",
        categoryImageUrl: "https://example.com/category-team.png",
        isRead: false,
        navigationType: "USER_LIST",
        deepLink: "pokit://shared?categoryId=20&userId=5",
        createdAt: "2026-04-06T11:00:00Z"
    )

    /// TC-35: deepLink 없는 알림
    static let featureSetting_noDeeplink = Self(
        id: 12,
        notificationType: "SYSTEM",
        title: "시스템 공지",
        body: "공지 내용입니다",
        categoryImageUrl: nil,
        isRead: false,
        navigationType: "NONE",
        deepLink: nil,
        createdAt: "2026-04-06T10:00:00Z"
    )

    /// TC-28: 10개 단위 페이지를 구성하기 위한 헬퍼
    static func featureSetting_item(id: Int, isRead: Bool = false) -> Self {
        Self(
            id: id,
            notificationType: "LINK_ADDED",
            title: "알림 \(id)",
            body: "알림 본문 \(id)",
            categoryImageUrl: "https://example.com/img-\(id).png",
            isRead: isRead,
            navigationType: "CONTENT_DETAIL",
            deepLink: "pokit://shared?categoryId=10&contentId=\(id)",
            createdAt: "2026-04-06T00:00:00Z"
        )
    }
}

extension NotificationListInquiryResponse {
    static let featureSetting_firstPageResponse: Self = featureSettingDecode([
        "data": [
            [
                "id": 1,
                "notificationType": "LINK_ADDED",
                "title": "'공유 포킷'에 링크가 추가되었어요",
                "body": "멤버가 추가한 링크를 확인해보세요",
                "categoryImageUrl": "https://example.com/category.png",
                "isRead": false,
                "navigationType": "CONTENT_DETAIL",
                "deepLink": "pokit://shared?categoryId=10&contentId=2",
                "createdAt": "2026-04-06T00:00:00Z"
            ],
            [
                "id": 2,
                "notificationType": "MEMBER_JOINED",
                "title": "새로운 멤버가 참여했어요",
                "body": "새 멤버를 확인해보세요",
                "categoryImageUrl": "https://example.com/category-2.png",
                "isRead": true,
                "navigationType": "USER_LIST",
                "deepLink": "pokit://shared?categoryId=10&userId=3",
                "createdAt": "2026-04-05T00:00:00Z"
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
    ])

    static let featureSetting_nextPageResponse: Self = featureSettingDecode([
        "data": [[
            "id": 3,
            "notificationType": "RESTRICTED",
            "title": "'공유 포킷' 포킷 사용이 제한되었어요",
            "body": "내보내기 처리된 포킷을 확인해보세요",
            "categoryImageUrl": "https://example.com/category-3.png",
            "isRead": false,
            "navigationType": "ALERT_BOX",
            "deepLink": "pokit://alert",
            "createdAt": "2026-04-04T00:00:00Z"
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
    ])

    static let featureSetting_emptyResponse: Self = featureSettingDecode([
        "data": [],
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

extension NotificationListInquiry {
    /// TC-28: 10개 항목이 있는 첫 번째 페이지 (hasNext=true)
    static let featureSetting_fullFirstPage: Self = .init(
        data: (1...10).map { NotificationItem.featureSetting_item(id: $0) },
        page: 0,
        size: 10,
        sort: [],
        hasNext: true
    )

    /// TC-28: 다음 페이지 5개 항목 (hasNext=false)
    static let featureSetting_secondPage: Self = .init(
        data: (11...15).map { NotificationItem.featureSetting_item(id: $0) },
        page: 1,
        size: 10,
        sort: [],
        hasNext: false
    )
}

extension NotificationListInquiryResponse {
    /// TC-28: 10개 항목이 있는 첫 번째 페이지 응답
    static let featureSetting_fullFirstPageResponse: Self = featureSettingDecode([
        "data": (1...10).map { id in
            [
                "id": id,
                "notificationType": "LINK_ADDED",
                "title": "알림 \(id)",
                "body": "알림 본문 \(id)",
                "categoryImageUrl": "https://example.com/img-\(id).png",
                "isRead": false,
                "navigationType": "CONTENT_DETAIL",
                "deepLink": "pokit://shared?categoryId=10&contentId=\(id)",
                "createdAt": "2026-04-06T00:00:00Z"
            ] as [String: Any]
        },
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
    ])

    /// TC-28: 다음 페이지 5개 항목 응답
    static let featureSetting_secondPageResponse: Self = featureSettingDecode([
        "data": (11...15).map { id in
            [
                "id": id,
                "notificationType": "LINK_ADDED",
                "title": "알림 \(id)",
                "body": "알림 본문 \(id)",
                "categoryImageUrl": "https://example.com/img-\(id).png",
                "isRead": false,
                "navigationType": "CONTENT_DETAIL",
                "deepLink": "pokit://shared?categoryId=10&contentId=\(id)",
                "createdAt": "2026-04-06T00:00:00Z"
            ] as [String: Any]
        },
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
    ])
}

extension NotificationClient {
    static func featureSettingTestValue(
        firstPage: NotificationListInquiryResponse = .featureSetting_firstPageResponse,
        nextPage: NotificationListInquiryResponse = .featureSetting_nextPageResponse,
        onRead: (@Sendable (Int) async throws -> Void)? = nil,
        onDelete: (@Sendable (Int) async throws -> Void)? = nil
    ) -> Self {
        var client = Self.testValue
        client.알림_목록_조회 = { request in
            request.page == 0 ? firstPage : nextPage
        }
        client.알림_읽음 = { id in
            if let onRead {
                try await onRead(id)
            }
        }
        client.알림_삭제 = { id in
            if let onDelete {
                try await onDelete(id)
            }
        }
        return client
    }
}
