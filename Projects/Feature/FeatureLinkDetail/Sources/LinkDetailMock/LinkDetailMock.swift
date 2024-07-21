//
//  LinkDetailMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 7/19/24.
//

import Foundation

public struct LinkDetailMock: Equatable {
    public let id: UUID
    public let title: String
    public let url: String
    public let createdAt: Date
    public let memo: String
    public let pokit: String
    public let isRemind: Bool
    public let isFavorite: Bool
    
    public init(
        id: UUID = .init(),
        title: String,
        url: String,
        createdAt: Date,
        memo: String,
        pokit: String,
        isRemind: Bool,
        isFavorite: Bool
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.createdAt = createdAt
        self.memo = memo
        self.pokit = pokit
        self.isRemind = isRemind
        self.isFavorite = isFavorite
    }
}
