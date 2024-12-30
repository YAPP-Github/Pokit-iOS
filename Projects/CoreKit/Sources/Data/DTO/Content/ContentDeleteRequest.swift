//
//  ContentDeleteRequest.swift
//  CoreKit
//
//  Created by asobi on 12/30/24.
//

import Foundation
/// 미분류 링크 삭제
public struct ContentDeleteRequest: Encodable {
    let contentId: [Int]
    
    public init(contentId: [Int]) {
        self.contentId = contentId
    }
}

extension ContentDeleteRequest {
    public static let mock: Self = Self(contentId: [551321312,4333333])
}
