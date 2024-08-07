//
//  FilterBottom.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public struct FilterBottom: Equatable {
    public var categoryList: BaseCategoryListInquiry
    
    public init() {
        self.categoryList = .init(
            data: [],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
    }
}
