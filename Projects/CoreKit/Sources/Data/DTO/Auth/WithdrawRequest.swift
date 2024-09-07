//
//  WithdrawRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 회원탈퇴 API Request
/// 📌 회원탈퇴는 Response가 없음
public struct WithdrawRequest: Encodable {
    public let authPlatform: String
    
    public init(authPlatform: String) {
        self.authPlatform = authPlatform
    }
}
