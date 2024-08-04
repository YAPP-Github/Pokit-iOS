//
//  SignupRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 회원 등록 API Request
public struct SignupRequest: Encodable {
    public let nickName: String
    public let interests: [String]
    
    public init(nickName: String, interests: [String]) {
        self.nickName = nickName
        self.interests = interests
    }
}
