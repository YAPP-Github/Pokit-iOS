//
//  AlertListInquiryResponse.swift
//  CoreKit
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

import Util
/// 알림 목록 조회 API Response
public struct AlertListInquiryResponse: Decodable {
    public let data: [AlertItemInquiryResponse]
    public let page: Int
    public let size: Int
    public let sort: [ItemInquirySortResponse]
    public let hasNext: Bool
}

public struct AlertItemInquiryResponse: Decodable {
    public let id: Int
    public let userId: Int
    public let contentId: Int
    public let thumbNail: String
    public let title: String
    public let body: String
    public let createdAt: String
}

extension AlertListInquiryResponse {
    static let mock: Self = Self(
        data: [
            AlertItemInquiryResponse(
                id: 999999,
                userId: 898989898,
                contentId: 21312,
                thumbNail: Constants.mockImageUrl,
                title: "제목타이틀",
                body: "바디",
                createdAt: ""
            )
        ],
        page: 1,
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

