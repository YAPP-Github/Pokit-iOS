//
//  SocialLoginProvider.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import SwiftUI

public enum SocialLoginProvider: String, Codable, Equatable {
    case apple = "애플"
    case google = "구글"
}

public extension SocialLoginProvider {
    var description: String { return self.rawValue }
}
