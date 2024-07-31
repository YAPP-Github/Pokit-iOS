//
//  SignupRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 회원 등록 API Request
public struct SignupRequest: Encodable {
    let nickname: String
    let interests: [String]
}
