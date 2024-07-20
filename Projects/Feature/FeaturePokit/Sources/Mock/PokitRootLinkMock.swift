//
//  PokitRootLinkMock.swift
//  FeaturePokit
//
//  Created by 김민호 on 7/17/24.
//

import Foundation

import Util

/// FeatureRemind와 똑같음 Mock이니 대충 끼워넣고 Domain에서 정립하기
public struct LinkMock: PokitLinkCardItem, Identifiable, Equatable {
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

public extension LinkMock {
    static var recommendedMock: [LinkMock] {
        [
            .init(
                title: "첫번째 항목일 때",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "두번째 항목일 때",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            ),
            .init(
                title: "세번째 항목일 때",
                thumbNail: "https://picsum.photos/seed/picsum/200/300",
                createAt: .now,
                categoryType: "텍스트",
                isRead: false,
                domain: "youtube"
            )
        ]
    }
}
