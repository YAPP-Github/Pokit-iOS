//
//  BasePageableRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// Pageable
public struct BasePageableRequest: Equatable, Encodable {
    public let page: Int
    public let size: Int
    public let sort: [String]
    
    public init(page: Int, size: Int, sort: [String]) {
        self.page = page
        self.size = size
        self.sort = sort
    }
}
