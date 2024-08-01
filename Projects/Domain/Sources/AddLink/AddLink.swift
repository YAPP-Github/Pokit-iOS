//
//  AddLink.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct AddLink {
    /// - Response, Request
    public let data: String
    public let title: String
    public let categoryId: Int
    public let memo: String
    public let alertYn: RemindState
    /// - Response
    public let categoryListInQuiry: BaseCategoryListInquiry
    /// - Request
    public let pageable: BasePageable
}

public extension AddLink {
    enum RemindState: String {
        case yes = "YES"
        case no = "NO"
    }
}
