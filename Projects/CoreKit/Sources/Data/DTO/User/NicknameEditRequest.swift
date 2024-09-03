//
//  NicknameEditRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 닉네임 수정 API Request
public struct NicknameEditRequest: Encodable {
    public let nickname: String
    
    public init(nickname: String) {
        self.nickname = nickname
    }
}
