//
//  BaseCondition.swift
//  Domain
//
//  Created by 김도형 on 8/9/24.
//

import Foundation

public struct BaseCondition: Equatable {
    public var categoryIds: [Int]
    public var isUnreadFlitered: Bool
    public var isFavoriteFlitered: Bool
    public var startDate: Date?
    public var endDate: Date?
}
