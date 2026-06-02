import Foundation

import CoreKit
import Domain
import Util

private func featureContentCardDecode<T: Decodable>(_ value: Any) -> T {
    let data = try! JSONSerialization.data(withJSONObject: value)
    return try! JSONDecoder().decode(T.self, from: data)
}

extension BaseCategoryResponse {
    static let featureContentCard_shared: Self = featureContentCardDecode([
        "categoryId": 77,
        "categoryName": "공유 포킷"
    ])
}

extension BaseContentItem {
    static let featureContentCard_authorVisible = Self(
        id: 101,
        categoryName: "공유 포킷",
        categoryId: 77,
        title: "작성자 프로필이 있는 링크",
        memo: "공유 링크 메모",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/author-visible",
        domain: "pokit.link",
        createdAt: "2026.04.06",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: 202,
        authorNickname: "공유멤버",
        authorProfileImageURL: "https://example.com/author-profile.png"
    )

    static let featureContentCard_favorite = Self(
        id: 102,
        categoryName: "내 포킷",
        categoryId: 78,
        title: "즐겨찾기 링크",
        memo: nil,
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/favorite",
        domain: "pokit.link",
        createdAt: "2026.04.05",
        isRead: false,
        isFavorite: true,
        keyword: nil,
        authorUserId: nil,
        authorNickname: nil,
        authorProfileImageURL: nil
    )

    static let featureContentCard_authorHidden = Self(
        id: 103,
        categoryName: "공유 포킷",
        categoryId: 77,
        title: "작성자 정보가 없는 링크",
        memo: "공유 링크 메모",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/author-hidden",
        domain: "pokit.link",
        createdAt: "2026.04.04",
        isRead: false,
        isFavorite: false,
        keyword: nil,
        authorUserId: nil,
        authorNickname: nil,
        authorProfileImageURL: nil
    )

    static let featureContentCard_personalized = Self(
        id: 104,
        categoryName: "공유 포킷",
        categoryId: 77,
        title: "개인화 상태 링크",
        memo: "공유 링크 메모",
        thumbNail: Constants.mockImageUrl,
        data: "https://pokit.link/personalized",
        domain: "pokit.link",
        createdAt: "2026.04.03",
        isRead: true,
        isFavorite: true,
        keyword: nil,
        authorUserId: 204,
        authorNickname: "공유멤버2",
        authorProfileImageURL: "https://example.com/author-profile-2.png"
    )
}

extension ContentDetailResponse {
    static let featureContentCard_detailResponse = Self(
        contentId: 101,
        category: .featureContentCard_shared,
        data: "https://pokit.link/author-visible",
        title: "작성자 프로필이 있는 링크",
        memo: "공유 링크 메모",
        alertYn: "NO",
        createdAt: "2026-04-06T00:00:00Z",
        favorites: false,
        keyword: nil,
        userNickname: "공유멤버",
        authorUserId: 202,
        authorNickname: "공유멤버",
        authorProfileImageURL: "https://example.com/author-profile.png"
    )

    static let featureContentCard_detailWithoutAuthor = Self(
        contentId: 103,
        category: .featureContentCard_shared,
        data: "https://pokit.link/author-hidden",
        title: "작성자 정보가 없는 링크",
        memo: "공유 링크 메모",
        alertYn: "NO",
        createdAt: "2026-04-04T00:00:00Z",
        favorites: false,
        keyword: nil,
        userNickname: "알 수 없음",
        authorUserId: nil,
        authorNickname: nil,
        authorProfileImageURL: nil
    )
}

extension ContentClient {
    static func featureContentCardTestValue(
        detailResponse: ContentDetailResponse = .featureContentCard_detailResponse,
        onFavorite: (@Sendable (String) async throws -> BookmarkResponse)? = nil,
        onUnfavorite: (@Sendable (String) async throws -> Void)? = nil,
        onThumbnailUpdate: (@Sendable (String, ThumbnailRequest) async throws -> Void)? = nil
    ) -> Self {
        var client = Self.testValue
        client.컨텐츠_상세_조회 = { _ in detailResponse }
        client.즐겨찾기 = { contentId in
            if let onFavorite {
                return try await onFavorite(contentId)
            }
            return .mock
        }
        client.즐겨찾기_취소 = { contentId in
            if let onUnfavorite {
                try await onUnfavorite(contentId)
            }
        }
        client.썸네일_수정 = { contentId, request in
            if let onThumbnailUpdate {
                try await onThumbnailUpdate(contentId, request)
            }
        }
        return client
    }
}

extension SwiftSoupClient {
    static func featureContentCardTestValue(
        imageURL: String = "https://example.com/updated-thumbnail.png"
    ) -> Self {
        var client = Self.testValue
        client.parseOGImageURL = { _ in imageURL }
        return client
    }
}
