//
//  BaseItemInquirySort.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct BaseItemInquirySort: Equatable {
    public var direction: String
    public var nullHandling: String
    public var ascending: Bool
    public var property: String
    public var ignoreCase: Bool
    
    public init(
        direction: String,
        nullHandling: String,
        ascending: Bool,
        property: String,
        ignoreCase: Bool
    ) {
        self.direction = direction
        self.nullHandling = nullHandling
        self.ascending = ascending
        self.property = property
        self.ignoreCase = ignoreCase
    }
}
