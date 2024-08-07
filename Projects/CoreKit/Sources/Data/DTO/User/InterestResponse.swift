//
//  InterestResponse.swift
//  CoreKit
//
//  Created by 김민호 on 8/6/24.
//

import Foundation
/// 관심사 목록 조회 API Response
public struct InterestResponse: Equatable, Decodable {
    public let code: String
    public let description: String
    
    public init(code: String, description: String) {
        self.code = code
        self.description = description
    }
}

extension InterestResponse {
    static var mock: [Self] = [
        Self(code: "code1", description: "빨래"),
        Self(code: "code2", description: "산책"),
        Self(code: "code3", description: "프로그래밍"),
        Self(code: "code4", description: "여행"),
        Self(code: "code5", description: "요리")
    ]
}
