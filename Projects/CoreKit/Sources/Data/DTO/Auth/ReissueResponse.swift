//
//  ReissueResponse.swift
//  CoreKit
//
//  Created by 김민호 on 8/6/24.
//

import Foundation
/// 액세스 토큰 재발급 API Response
public struct ReissueResponse: Decodable {
    public let accessToken: String
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}
extension ReissueResponse {
    static let mock: Self = Self(accessToken: "accessToken(mock)")
}
