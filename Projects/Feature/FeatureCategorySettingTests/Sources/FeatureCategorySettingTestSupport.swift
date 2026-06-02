import CoreKit
import Domain
import Util
import UserNotifications

extension BaseCategoryImage {
    static let featureCategorySetting_image = Self(
        imageId: 7,
        imageURL: Constants.mockImageUrl
    )
}

extension BaseCategoryItem {
    static let featureCategorySetting_editTarget = Self(
        id: 42,
        userId: 100,
        categoryName: "공유 포킷",
        categoryImage: .featureCategorySetting_image,
        contentCount: 3,
        createdAt: "2026-05-19",
        openType: .공개,
        keywordType: .IT,
        userCount: 2,
        isFavorite: false,
        alertEnabled: true
    )

    static let featureCategorySetting_alertDisabledEditTarget = Self(
        id: 43,
        userId: 100,
        categoryName: "알림 꺼진 포킷",
        categoryImage: .featureCategorySetting_image,
        contentCount: 3,
        createdAt: "2026-05-19",
        openType: .공개,
        keywordType: .IT,
        userCount: 2,
        isFavorite: false,
        alertEnabled: false
    )
}

extension CategoryClient {
    static func featureCategorySettingTestValue(
        onUpdate: (@Sendable (Int, CategoryEditRequest) async throws -> CategoryEditResponse)? = nil,
        onProfileList: (@Sendable () async throws -> [CategoryImageResponse])? = nil
    ) -> Self {
        Self(
            카테고리_삭제: { _ in },
            카테고리_수정: { categoryId, request in
                if let onUpdate {
                    return try await onUpdate(categoryId, request)
                }
                return .mock
            },
            카테고리_목록_조회: { _, _, _ in .mock },
            카테고리_생성: { _ in .mock },
            카테고리_프로필_목록_조회: {
                if let onProfileList {
                    return try await onProfileList()
                }
                return CategoryImageResponse.mock
            },
            유저_카테고리_개수_조회: { .mock },
            카테고리_상세_조회: { _ in .mock },
            공유받은_카테고리_조회: { _, _ in .mock },
            공유받은_카테고리_저장: { _ in },
            포킷_초대된_유저_목록_조회: { _ in [.mock] },
            포킷_내보내기: { _, _ in },
            포킷_나가기: { _ in },
            포킷_초대_수락: { _ in }
        )
    }
}

extension UserNotificationClient {
    static func featureCategorySettingTestValue(
        authorizationStatus: UNAuthorizationStatus
    ) -> Self {
        var client = Self.noop
        client.getNotificationSettings = {
            Notification.Settings(authorizationStatus: authorizationStatus)
        }
        return client
    }
}

extension UserDefaultsClient {
    static let featureCategorySettingTestValue = Self(
        boolKey: { _ in false },
        stringKey: { _ in nil },
        stringArrayKey: { _ in [] },
        removeBool: { _ in },
        removeString: { _ in },
        removeStringArray: { _ in },
        setBool: { _, _ in },
        setString: { _, _ in },
        setStringArray: { _, _ in }
    )
}
