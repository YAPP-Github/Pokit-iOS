//
//  PokitRootCardMock.swift
//  FeaturePokit
//
//  Created by 김민호 on 7/16/24.
//

import Foundation
import Util

public struct PokitRootCardMock: Identifiable, Equatable, PokitCardItem {
    public let id = UUID()
    public let categoryType: String
    public let contentSize: Int
    public let thumbNail: String
    let createAt: String
}

public extension PokitRootCardMock {
    static var mock: [Self] = [
        Self(
            categoryType: "요리/레시피",
            contentSize: 10,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-06-13"
        ),
        Self(
            categoryType: "디자인",
            contentSize: 6,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-06-14"
        ),
        Self(
            categoryType: "프로그래밍",
            contentSize: 6,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-06-16"
        ),
        Self(
            categoryType: "운동",
            contentSize: 6,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-06-18"
        ),
        Self(
            categoryType: "맛집",
            contentSize: 6,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-06-19"
        ),
        Self(
            categoryType: "여행",
            contentSize: 6,
            thumbNail: "https://picsum.photos/seed/picsum/200/300",
            createAt: "2024-07-22"
        ),
    ]
}
