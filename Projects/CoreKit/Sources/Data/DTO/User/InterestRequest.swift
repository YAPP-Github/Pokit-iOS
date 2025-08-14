//
//  InterestRequest.swift
//  CoreKit
//
//  Created by 김도형 on 3/1/25.
//

import Foundation

public struct InterestRequest: Encodable {
    public let interests: [String]
    
    public init(interests: [String]) {
        self.interests = interests
    }
}
