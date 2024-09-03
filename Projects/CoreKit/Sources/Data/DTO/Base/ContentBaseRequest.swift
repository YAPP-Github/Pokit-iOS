//
//  ContentBaseRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 컨텐츠 상세조회, 컨텐츠 수정, 컨텐츠 추가 API Request
public struct ContentBaseRequest: Encodable {
    let data: String
    let title: String
    let categoryId: Int
    let memo: String
    let alertYn: String
    let thumbNail: String?
    
    public init(
        data: String,
        title: String,
        categoryId: Int,
        memo: String,
        alertYn: String,
        thumbNail: String?
    ) {
        self.data = data
        self.title = title
        self.categoryId = categoryId
        self.memo = memo
        self.alertYn = alertYn
        self.thumbNail = thumbNail
    }
}
