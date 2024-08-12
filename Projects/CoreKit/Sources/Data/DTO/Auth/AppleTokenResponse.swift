//
//  AppleTokenResponse.swift
//  CoreKit
//
//  Created by 김민호 on 8/12/24.
//

import Foundation
/// Refresh토큰을 받기 위한 Apple Token Response
public struct AppleTokenResponse: Decodable {
    public let refresh_token: String
}
