//
//  BaseContentListInQuiry.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct BaseContentListInquiry {
    public let data: [BaseContent]
    public let page: Int
    public let size: Int
    public let sort: [BaseItemInquirySort]
    public let hasNext: Bool
}
