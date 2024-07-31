//
//  SignInRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// - 로그인 API Request
public struct SignInRequest: Encodable {
    let authPlatform: String
    let idToken: String
}
