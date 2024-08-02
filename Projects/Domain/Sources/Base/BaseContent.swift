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
    public let title: String
    public let thumbNail: String
    public let data: String
    public let createdAt: Date
    public let isRead: Bool
    public let favorites: Bool
}
