//
//  ContentMoveRequest.swift
//  CoreKit
//
//  Created by 김민호 on 12/29/24.
//
import Foundation
/// 미분류 링크를 카테고리로 이동
public struct ContentMoveRequest: Encodable {
    let contentIds: [Int]
    let categoryId: Int
    
    public init(contentIds: [Int], categoryId: Int) {
        self.contentIds = contentIds
        self.categoryId = categoryId
    }
}

extension ContentMoveRequest {
    public static let mock: Self = Self(contentIds: [123,456], categoryId: 444)
}
