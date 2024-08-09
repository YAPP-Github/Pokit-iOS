//
//  BaseConditionRequest.swift
//  CoreKit
//
//  Created by 김도형 on 8/9/24.
//

import Foundation

public struct BaseConditionRequest: Decodable {
    public var categoryIds: [Int]
    public var isUnreadFiltered: Bool
    public var isFavoriteFlitered: Bool
    public var startDate: Date?
    public var endDate: Date?
    
    public init(
        categoryIds: [Int],
        isRead: Bool,
        favorites: Bool,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.categoryIds = categoryIds
        self.isUnreadFiltered = isRead
        self.isFavoriteFlitered = favorites
        self.startDate = startDate
        self.endDate = endDate
    }
}
