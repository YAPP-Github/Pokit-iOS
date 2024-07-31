//
//  BasePageableRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// Pageable
public struct BasePageableRequest: Encodable {
    let page: Int
    let size: Int
    let sort: [String]
}
