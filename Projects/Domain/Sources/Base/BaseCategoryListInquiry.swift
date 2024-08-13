//
//  CategoryListInquiry.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct BaseCategoryListInquiry: Equatable {
    public var data: [BaseCategoryItem]
    public var page: Int
    public var size: Int
    public var sort: [BaseItemInquirySort]
    public var hasNext: Bool
    
    public init(
        data: [BaseCategoryItem],
        page: Int,
        size: Int,
        sort: [BaseItemInquirySort],
        hasNext: Bool
    ) {
        self.data = data
        self.page = page
        self.size = size
        self.sort = sort
        self.hasNext = hasNext
    }
}
