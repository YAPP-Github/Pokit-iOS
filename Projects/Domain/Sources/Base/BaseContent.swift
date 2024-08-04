//
//  BaseContent.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseContent: Identifiable, Equatable, PokitLinkCardItem {
    public let id: Int
    public let categoryName: String
    public let categoryId: Int?
    public let title: String
    public let thumbNail: String
    public let data: String
    public let memo: String
    public let createdAt: Date
    public let isRead: Bool
    public let favorites: Bool
    public let alertYn: RemindState
}

public extension BaseContent {
    enum RemindState: String, Equatable {
        case yes = "YES"
        case no = "NO"
    }
}
