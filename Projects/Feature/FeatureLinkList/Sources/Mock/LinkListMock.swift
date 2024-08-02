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
    public let createAt: Date
    public let categoryType: String
    public let isRead: Bool
    public let domain: String
    
    init(
        id: UUID = .init(),
        title: String,
        thumbNail: String,
        createAt: Date,
        categoryType: String,
        isRead: Bool,
        domain: String
    ) {
        self.id = id
        self.title = title
        self.thumbNail = thumbNail
        self.createAt = createAt
        self.categoryType = categoryType
        self.isRead = isRead
        self.domain = domain
    }
}

extension LinkListMock {
    static var listMock: [LinkListMock] {
        [
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            )
        ]
    }
}
