//
//  SocialLoginProvider.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import SwiftUI

public enum SocialLoginProvider: String, Codable {
    case apple
    case google
}

public extension SocialLoginProvider {
    var description: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        }
    }
}
