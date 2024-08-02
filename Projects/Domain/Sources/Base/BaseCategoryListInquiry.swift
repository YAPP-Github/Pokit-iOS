//
//  CategoryListInquiry.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct BaseCategoryListInquiry {
    public let data: [BaseCategory]
    public let page: Int
    public let size: Int
    public let sort: [BaseItemInquirySort]
    public let hasNext: Bool
}
