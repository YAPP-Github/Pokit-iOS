//
//  BaseInterest+Extension.swift
//  Domain
//
//  Created by 김도형 on 1/29/25.
//

import Foundation

import CoreKit

public extension InterestResponse {
    func toDomian() -> BaseInterest {
        return BaseInterest(
            code: self.code,
            description: self.description
        )
    }
}
