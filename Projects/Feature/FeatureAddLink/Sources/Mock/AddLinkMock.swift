//
//  AddLinkMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 7/18/24.
//

import Foundation

import Util

public struct AddLinkMock: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let urlText: String
    public let createAt: Date
    public let memo: String
    public let isRemind: Bool
    public let pokit: PokitMock
    
    public init(
        id: UUID = .init(),
        title: String,
        urlText: String,
        createAt: Date,
        memo: String,
        isRemind: Bool,
        pokit: PokitMock
    ) {
        self.id = id
        self.title = title
        self.urlText = urlText
        self.createAt = createAt
        self.memo = memo
        self.isRemind = isRemind
        self.pokit = pokit
    }
}
