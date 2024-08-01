//
//  Login.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct Login {
    // - MARK: Response
    public let accessToken: String
    public let refreshToken: String
    // - MARK: Request
    public let authPlatform: String
    public let idToken: String
}
