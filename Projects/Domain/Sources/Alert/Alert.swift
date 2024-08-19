//
//  Alert.swift
//  Domain
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

public struct Alert: Equatable {
    public let alertId: String
    public let pagable: BasePageable
    public var alertList: AlertListInquiry
    
    public init() {
        self.alertId = ""
        self.pagable = .init(
            page: 0,
            size: 10,
            sort: ["createdAt, desc"]
        )
        self.alertList = .init(
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
    }
}
