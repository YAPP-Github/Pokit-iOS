//
//  CategoryListInquiryRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 포킷 목록 조회 API  Request(URL)
public struct CategoryListInquiryRequest: Encodable {
    let page: Int
    let size: Int
    let sort: [String]
}
