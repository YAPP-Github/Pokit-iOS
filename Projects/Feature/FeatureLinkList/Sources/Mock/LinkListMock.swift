//
//  LinkListMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 8/2/24.
//

import Foundation

import Util

public struct LinkListMock: PokitLinkCardItem, Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let thumbNail: String
    public let isRead: Bool
    public var createdAt: Date
    public var categoryName: String
    public var data: String
    
    init(
        id: UUID = .init(),
        title: String,
        thumbNail: String,
        isRead: Bool,
        createdAt: Date,
        categoryName: String,
        data: String
    ) {
        self.id = id
        self.title = title
        self.thumbNail = thumbNail
        self.isRead = isRead
        self.createdAt = createdAt
        self.categoryName = categoryName
        self.data = data
    }
}

extension LinkListMock {
    static var listMock: [LinkListMock] {
        [
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                isRead: false,
                createdAt: .now,
                categoryName: "텍스트",
                data: "youtube"
            )
        ]
    }
}
