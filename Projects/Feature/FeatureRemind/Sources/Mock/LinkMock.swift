//
//  LinkMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 7/12/24.
//

import Foundation

import Util

public struct LinkMock: PokitLinkCardItem, Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let thumbNail: String
    public let createdAt: Date
    public let categoryName: String
    public let isRead: Bool
    public let data: String
    
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
        self.createdAt = createAt
        self.categoryName = categoryType
        self.isRead = isRead
        self.data = domain
    }
}

extension LinkMock {
    static var recommendedMock: [LinkMock] {
        [
            .init(
                title: "바이오 연구의 첨단,인공 유전자로 인간 피부 재생 가능성",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "바이오 연구의 첨단,인공 유전자로 인간 피부 재생 가능성",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "바이오 연구의 첨단,인공 유전자로 인간 피부 재생 가능성",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            )
        ]
    }
    
    static var unreadMock: [LinkMock] {
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
            )
        ]
    }
    
    static var favoriteMock: [LinkMock] {
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
            )
        ]
    }
}
