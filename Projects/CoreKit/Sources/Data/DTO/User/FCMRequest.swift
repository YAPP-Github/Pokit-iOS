//
//  FCMRequest.swift
//  CoreKit
//
//  Created by 김민호 on 8/27/24.
//

import Foundation

public struct FCMRequest: Encodable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}


