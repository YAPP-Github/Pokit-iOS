//
//  MainTabDeeplinkTestDependencies.swift
//  App
//
//  Created by 김도형 on 2/18/26.
//

import Foundation

import CoreKit
import Dependencies

extension DependencyValues {
    mutating func applyMainTabDeeplinkTestDependencies(
        deeplinkRouteClient: DeeplinkRouteClient = .liveValue
    ) {
        self[CategoryClient.self] = .mainTabDeeplinkTestValue
        self[ContentClient.self] = .mainTabDeeplinkTestValue
        self[UserClient.self] = .mainTabDeeplinkTestValue
        self[AuthClient.self] = .mainTabDeeplinkTestValue
        self[VersionClient.self] = .mainTabDeeplinkTestValue
        self[UserDefaultsClient.self] = .mainTabDeeplinkTestValue
        self[NotificationClient.self] = .mainTabDeeplinkTestValue
        self[PasteboardClient.self] = .noop
        self[DeeplinkRouteClient.self] = deeplinkRouteClient
    }
}

extension CategoryClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        카테고리_삭제: { _ in },
        카테고리_수정: { categoryId, _ in
            MainTabDeeplinkTestFixtures.categoryDetailResponse(categoryId: categoryId)
        },
        카테고리_목록_조회: { _, _, _ in
            let delay = await MainTabDeeplinkRouteOrder.shared.nextDelayNanoseconds()
            try? await Task.sleep(nanoseconds: delay)
            return MainTabDeeplinkTestFixtures.categoryListResponse
        },
        카테고리_생성: { _ in
            MainTabDeeplinkTestFixtures.categoryDetailResponse(categoryId: 2)
        },
        카테고리_프로필_목록_조회: {
            MainTabDeeplinkTestFixtures.categoryImageResponses
        },
        유저_카테고리_개수_조회: {
            MainTabDeeplinkTestFixtures.categoryCountResponse
        },
        카테고리_상세_조회: { categoryId in
            MainTabDeeplinkTestFixtures.categoryDetailResponse(
                categoryId: Int(categoryId) ?? 2
            )
        },
        공유받은_카테고리_조회: { categoryId, _ in
            MainTabDeeplinkTestFixtures.sharedCategoryResponse(
                categoryId: Int(categoryId) ?? 2
            )
        },
        공유받은_카테고리_저장: { _ in },
        포킷_초대된_유저_목록_조회: { categoryId in
            MainTabDeeplinkTestFixtures.invitedUserResponses(categoryId: categoryId)
        },
        포킷_내보내기: { _, _ in },
        포킷_나가기: { _ in },
        포킷_초대_수락: { _ in }
    )
}

extension ContentClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        컨텐츠_삭제: { _ in },
        컨텐츠_상세_조회: { contentId in
            MainTabDeeplinkTestFixtures.contentDetailResponse(
                contentId: Int(contentId) ?? 777
            )
        },
        컨텐츠_수정: { contentId, _ in
            MainTabDeeplinkTestFixtures.contentDetailResponse(
                contentId: Int(contentId) ?? 777
            )
        },
        컨텐츠_추가: { _ in
            MainTabDeeplinkTestFixtures.contentDetailResponse(contentId: 777)
        },
        즐겨찾기: { contentId in
            MainTabDeeplinkTestFixtures.bookmarkResponse(
                contentId: Int(contentId) ?? 777
            )
        },
        즐겨찾기_취소: { _ in },
        카테고리_내_컨텐츠_목록_조회: { categoryId, _, _ in
            MainTabDeeplinkTestFixtures.contentListResponse(
                categoryId: Int(categoryId) ?? 2
            )
        },
        미분류_카테고리_컨텐츠_조회: { _ in
            MainTabDeeplinkTestFixtures.emptyContentListResponse
        },
        컨텐츠_검색: { _, _ in
            MainTabDeeplinkTestFixtures.contentListResponse(categoryId: 2)
        },
        썸네일_수정: { _, _ in },
        미분류_링크_포킷_이동: { _ in },
        미분류_링크_삭제: { _ in },
        추천_컨텐츠_조회: { _, _ in
            MainTabDeeplinkTestFixtures.contentListResponse(categoryId: 2)
        },
        컨텐츠_신고사유_조회: { [ReportReasonResponse.mock] },
        컨텐츠_신고: { _ in },
        컨텐츠_신고_사유: { _, _ in }
    )
}

extension NotificationClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        알림_목록_조회: { _ in MainTabDeeplinkTestFixtures.notificationListResponse },
        알림_읽음: { _ in },
        알림_삭제: { _ in }
    )
}

extension UserClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        프로필_수정: { _ in MainTabDeeplinkTestFixtures.baseUserResponse },
        닉네임_수정: { _ in MainTabDeeplinkTestFixtures.baseUserResponse },
        회원등록: { _ in MainTabDeeplinkTestFixtures.baseUserResponse },
        닉네임_중복_체크: { _ in MainTabDeeplinkTestFixtures.nicknameCheckResponse },
        관심사_목록_조회: { MainTabDeeplinkTestFixtures.interests },
        닉네임_조회: { MainTabDeeplinkTestFixtures.baseUserResponse },
        fcm_토큰_저장: { _ in MainTabDeeplinkTestFixtures.fcmResponse },
        프로필_이미지_목록_조회: { MainTabDeeplinkTestFixtures.profileImages },
        유저_관심사_목록_조회: { MainTabDeeplinkTestFixtures.interests },
        관심사_수정: { _ in }
    )
}

extension AuthClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        로그인: { _ in MainTabDeeplinkTestFixtures.tokenResponse },
        회원탈퇴: { _ in },
        토큰재발급: { _ in ReissueResponse(accessToken: "uitest-access-token") },
        apple: { _ in MainTabDeeplinkTestFixtures.appleTokenResponse },
        appleRevoke: { _, _ in }
    )
}

extension VersionClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        버전체크: { MainTabDeeplinkTestFixtures.versionResponse }
    )
}

extension UserDefaultsClient {
    static let mainTabDeeplinkTestValue: Self = .init(
        boolKey: { _ in false },
        stringKey: { _ in nil },
        stringArrayKey: { _ in nil },
        removeBool: { _ in },
        removeString: { _ in },
        removeStringArray: { _ in },
        setBool: { _, _ in },
        setString: { _, _ in },
        setStringArray: { _, _ in }
    )
}

private actor MainTabDeeplinkRouteOrder {
    static let shared = MainTabDeeplinkRouteOrder()

    private var requestCount = 0

    func nextDelayNanoseconds() -> UInt64 {
        requestCount += 1
        return UInt64(requestCount) * 30_000_000
    }
}

private enum MainTabDeeplinkTestFixtures {
    private static let category2ID = 2
    private static let category3ID = 3
    private static let category2Name = "UITest-Category-2"
    private static let category3Name = "UITest-Category-3"

    static let interests: [InterestResponse] = [
        .init(code: "it", description: "IT"),
        .init(code: "design", description: "디자인")
    ]

    static let categoryListResponse: CategoryListInquiryResponse = decode(
        [
            "data": [
                categoryItem(
                    id: category2ID,
                    name: category2Name,
                    contentCount: 2,
                    userCount: 2
                ),
                categoryItem(
                    id: category3ID,
                    name: category3Name,
                    contentCount: 1,
                    userCount: 2
                )
            ],
            "page": 0,
            "size": 30,
            "sort": [sort()],
            "hasNext": false
        ]
    )

    static let categoryImageResponses: [CategoryImageResponse] = decode(
        [
            ["imageId": 2002, "imageUrl": "https://example.com/category-2.png"],
            ["imageId": 2003, "imageUrl": "https://example.com/category-3.png"]
        ]
    )

    static let categoryCountResponse: CategoryCountResponse = decode(
        ["categoryTotalCount": 2]
    )

    static let baseUserResponse: BaseUserResponse = decode(
        [
            "id": 100,
            "email": "uitest@pokit.app",
            "nickname": "UITestUser",
            "profileImage": ["id": 10, "url": "https://example.com/profile.png"]
        ]
    )

    static let nicknameCheckResponse: NicknameCheckResponse = decode(
        ["isDuplicate": false]
    )

    static let profileImages: [BaseProfileImageResponse] = decode(
        [
            ["id": 10, "url": "https://example.com/profile.png"]
        ]
    )

    static let fcmResponse: FCMResponse = decode(
        ["userId": 100, "token": "uitest-fcm-token"]
    )

    static let tokenResponse: TokenResponse = decode(
        [
            "accessToken": "uitest-access-token",
            "refreshToken": "uitest-refresh-token",
            "isRegistered": true
        ]
    )

    static let appleTokenResponse: AppleTokenResponse = decode(
        ["refresh_token": "uitest-apple-refresh-token"]
    )

    static let versionResponse: VersionResponse = decode(
        [
            "results": [
                ["version": "1.0.0", "trackId": 2415354644]
            ]
        ]
    )

    static let notificationListResponse: NotificationListInquiryResponse = decode(
        [
            "data": [
                [
                    "id": 1,
                    "notificationType": "LINK_ADDED",
                    "title": "'뜨개질' 포킷에 링크가 추가되었어요",
                    "body": "OO님이 추가한 링크를 지금 확인해보세요",
                    "categoryImageUrl": "https://example.com/category-2.png",
                    "isRead": false,
                    "navigationType": "CONTENT_DETAIL",
                    "deepLink": "pokit://shared?categoryId=2&contentId=777",
                    "createdAt": "2026-02-18T00:00:00Z"
                ]
            ],
            "page": 0,
            "size": 30,
            "sort": [sort()],
            "hasNext": false
        ]
    )

    static let emptyContentListResponse: ContentListInquiryResponse = decode(
        [
            "data": [],
            "page": 0,
            "size": 30,
            "sort": [sort()],
            "hasNext": false
        ]
    )

    static func categoryDetailResponse(categoryId: Int) -> CategoryEditResponse {
        decode(
            [
                "categoryId": categoryId,
                "categoryName": categoryName(for: categoryId),
                "categoryImage": [
                    "imageId": 2000 + categoryId,
                    "imageUrl": "https://example.com/category-\(categoryId).png"
                ],
                "alertEnabled": true
            ]
        )
    }

    static func sharedCategoryResponse(categoryId: Int) -> SharedCategoryResponse {
        decode(
            [
                "category": [
                    "categoryId": categoryId,
                    "categoryName": categoryName(for: categoryId),
                    "contentCount": 1,
                    "categoryImageId": 2000 + categoryId,
                    "categoryImageUrl": "https://example.com/category-\(categoryId).png"
                ],
                "contents": [
                    "data": [
                        [
                            "contentId": 777,
                            "data": "https://example.com/777",
                            "domain": "example.com",
                            "title": "UITest-Content-777",
                            "memo": "uitest memo",
                            "thumbNail": "https://example.com/thumb-777.png",
                            "createdAt": "2026-02-18T00:00:00Z",
                            "authorUserId": 100,
                            "authorNickname": "UITestUser",
                            "authorProfileImageURL": "https://example.com/profile.png"
                        ]
                    ],
                    "page": 0,
                    "size": 30,
                    "sort": [sort()],
                    "hasNext": false
                ]
            ]
        )
    }

    static func invitedUserResponses(categoryId: Int) -> [InvitedUserResponse] {
        decode(
            [
                [
                    "userId": 1000 + categoryId,
                    "nickname": "Owner-\(categoryId)",
                    "profileImage": [
                        "id": 1000 + categoryId,
                        "url": "https://example.com/owner-\(categoryId).png"
                    ]
                ],
                [
                    "userId": 2000 + categoryId,
                    "nickname": "Member-\(categoryId)A",
                    "profileImage": NSNull()
                ]
            ]
        )
    }

    static func contentListResponse(categoryId: Int) -> ContentListInquiryResponse {
        switch categoryId {
        case category2ID:
            return decode(
                [
                    "data": [
                        contentBase(
                            contentId: 777,
                            categoryId: category2ID,
                            categoryName: category2Name,
                            title: "UITest-Content-777"
                        ),
                        contentBase(
                            contentId: 778,
                            categoryId: category2ID,
                            categoryName: category2Name,
                            title: "UITest-Content-778"
                        )
                    ],
                    "page": 0,
                    "size": 30,
                    "sort": [sort()],
                    "hasNext": false
                ]
            )
        case category3ID:
            return decode(
                [
                    "data": [
                        contentBase(
                            contentId: 888,
                            categoryId: category3ID,
                            categoryName: category3Name,
                            title: "UITest-Content-888"
                        )
                    ],
                    "page": 0,
                    "size": 30,
                    "sort": [sort()],
                    "hasNext": false
                ]
            )
        default:
            return emptyContentListResponse
        }
    }

    static func contentDetailResponse(contentId: Int) -> ContentDetailResponse {
        switch contentId {
        case 777:
            return decode(
                contentDetail(
                    contentId: 777,
                    categoryId: category2ID,
                    categoryName: category2Name,
                    title: "UITest-Content-777"
                )
            )
        case 778:
            return decode(
                contentDetail(
                    contentId: 778,
                    categoryId: category2ID,
                    categoryName: category2Name,
                    title: "UITest-Content-778"
                )
            )
        case 888:
            return decode(
                contentDetail(
                    contentId: 888,
                    categoryId: category3ID,
                    categoryName: category3Name,
                    title: "UITest-Content-888"
                )
            )
        default:
            return decode(
                contentDetail(
                    contentId: contentId,
                    categoryId: category2ID,
                    categoryName: category2Name,
                    title: "UITest-Content-\(contentId)"
                )
            )
        }
    }

    static func bookmarkResponse(contentId: Int) -> BookmarkResponse {
        decode(["contentId": contentId])
    }

    private static func categoryName(for id: Int) -> String {
        switch id {
        case category2ID: return category2Name
        case category3ID: return category3Name
        default: return "UITest-Category-\(id)"
        }
    }

    private static func sort() -> [String: Any] {
        [
            "direction": "DESC",
            "nullHandling": "NATIVE",
            "ascending": false,
            "property": "createdAt",
            "ignoreCase": false
        ]
    }

    private static func categoryItem(
        id: Int,
        name: String,
        contentCount: Int,
        userCount: Int
    ) -> [String: Any] {
        [
            "categoryId": id,
            "userId": 100,
            "categoryName": name,
            "categoryImage": [
                "imageId": 2000 + id,
                "imageUrl": "https://example.com/category-\(id).png"
            ],
            "contentCount": contentCount,
            "createdAt": "2026-02-18T00:00:00Z",
            "openType": "PUBLIC",
            "keywordType": "default",
            "userCount": userCount,
            "isFavorite": false,
            "alertEnabled": true
        ]
    }

    private static func contentBase(
        contentId: Int,
        categoryId: Int,
        categoryName: String,
        title: String
    ) -> [String: Any] {
        [
            "contentId": contentId,
            "category": [
                "categoryId": categoryId,
                "categoryName": categoryName
            ],
            "data": "https://example.com/\(contentId)",
            "domain": "example.com",
            "title": title,
            "memo": "memo-\(contentId)",
            "thumbNail": "https://example.com/thumb-\(contentId).png",
            "createdAt": "2026-02-18T00:00:00Z",
            "isRead": false,
            "isFavorite": false,
            "keyword": NSNull(),
            "author": [
                "userId": 100,
                "nickname": "UITestUser",
                "profileImageUrl": "https://example.com/profile.png"
            ],
            "memoExists": true
        ]
    }

    private static func contentDetail(
        contentId: Int,
        categoryId: Int,
        categoryName: String,
        title: String
    ) -> [String: Any] {
        [
            "contentId": contentId,
            "category": [
                "categoryId": categoryId,
                "categoryName": categoryName
            ],
            "data": "https://example.com/\(contentId)",
            "title": title,
            "memo": "memo-\(contentId)",
            "alertYn": "NO",
            "createdAt": "2026-02-18T00:00:00Z",
            "favorites": false,
            "keyword": "예능",
            "userNickname": "UITestUser",
            "author": [
                "userId": 100,
                "nickname": "UITestUser",
                "profileImageUrl": "https://example.com/profile.png"
            ]
        ]
    }

    private static func decode<T: Decodable>(_ jsonObject: Any) -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("UITest fixture decode failed for \(T.self): \(error)")
        }
    }
}
