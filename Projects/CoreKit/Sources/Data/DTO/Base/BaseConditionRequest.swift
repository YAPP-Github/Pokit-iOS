//
//  BaseConditionRequest.swift
//  CoreKit
//
//  Created by 김도형 on 8/9/24.
//

import Foundation

public struct BaseConditionRequest: Decodable {
    public var searchWord: String
    public var categoryIds: [Int]
    public var isUnreadFiltered: Bool
    public var isFavoriteFlitered: Bool
    public var startDate: String?
    public var endDate: String?
    
    public init(
        searchWord: String = "",
        categoryIds: [Int],
        isRead: Bool,
        favorites: Bool,
        startDate: String? = nil,
        endDate: String? = nil
    ) {
        self.searchWord = searchWord
        self.categoryIds = categoryIds
        self.isUnreadFiltered = isRead
        self.isFavoriteFlitered = favorites
        self.startDate = startDate
        self.endDate = endDate
    }
}
