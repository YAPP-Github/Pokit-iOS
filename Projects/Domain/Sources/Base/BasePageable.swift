//
//  BasePageable.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct BasePageable: Equatable {
    public var page: Int
    public var size: Int
    public var sort: [String]
}
