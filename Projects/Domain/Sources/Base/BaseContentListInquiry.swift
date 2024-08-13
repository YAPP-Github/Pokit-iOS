//
//  BaseContentListInQuiry.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct BaseContentListInquiry: Equatable {
    public var data: [BaseContentItem]
    public var page: Int
    public var size: Int
    public var sort: [BaseItemInquirySort]
    public var hasNext: Bool
    
    public init(
        data: [BaseContentItem],
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
