//
//  ContentListInquiryResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 카테고리 내 컨텐츠 목록 조회 API Response
public struct ContentListInquiryResponse: Decodable {
    let data: [ContentItemInquiryResponse]
    let page: Int
    let size: Int
    let sort: [ItemInquirySortResponse]
    let hasNext: Bool
}

public struct ContentItemInquiryResponse: Decodable {
    let id: Int
    let categoryId: Int
    let type: String
    let data: String
    let title: String
    let memo: String
    let alertYn: String
    let createdAt: String
}

extension ContentListInquiryResponse {
    public static var mock: Self = Self(
        data: [
            ContentItemInquiryResponse(
                id: 88,
                categoryId: 40000,
                type: "LINK",
                data: "DATA(mock)",
                title: "TITLE(mock)",
                memo: "MEMO(mock)",
                alertYn: "alertYn(mock)",
                createdAt: "2024-07-31T10:10:23.902Z"
            )
        ],
        page: 7,
        size: 4,
        sort: [
            ItemInquirySortResponse(
                direction: "",
                nullHandling: "",
                ascending: false,
                property: "",
                ignoreCase: false
            )
        ],
        hasNext: false
    )
}
