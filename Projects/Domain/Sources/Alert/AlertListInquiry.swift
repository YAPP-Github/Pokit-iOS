//
//  AlertListInquiry.swift
//  Domain
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

public struct AlertListInquiry: Equatable {
    public var data: [AlertItem]?
    public var page: Int
    public var size: Int
    public var sort: [BaseItemInquirySort]
    public var hasNext: Bool
}
