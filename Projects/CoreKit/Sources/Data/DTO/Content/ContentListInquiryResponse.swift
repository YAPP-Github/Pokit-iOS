//
//  ContentListInquiryResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 카테고리 내 컨텐츠 목록 조회 API Response
public struct ContentListInquiryResponse: Decodable {
    public let data: [ContentBaseResponse]
    public let page: Int
    public let size: Int
    public let sort: [ItemInquirySortResponse]
    public let hasNext: Bool
}

extension ContentListInquiryResponse {
    public static var mock: Self = Self(
        data: [
            ContentBaseResponse.mock(id: 0),
            ContentBaseResponse.mock(id: 1),
            ContentBaseResponse.mock(id: 2)
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
