//
//  BaseInterest.swift
//  Domain
//
//  Created by 김도형 on 1/29/25.
//

import Foundation

public struct BaseInterest: Equatable, Identifiable, Hashable {
    public let id = UUID()
    public let code: String
    public let description: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    public static func ==(lhs: BaseInterest, rhs: BaseInterest) -> Bool {
        lhs.code == rhs.code
    }
    
    public init(code: String, description: String) {
        self.code = code
        self.description = description
    }
}
