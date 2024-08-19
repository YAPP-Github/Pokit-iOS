//
//  AlertItem.swift
//  Domain
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

public struct AlertItem: Identifiable, Equatable {
    public let id: Int
    public let userId: Int
    public let contentId: Int
    public var thumbNail: String
    public var title: String
    public var body: String
    public let createdAt: String
    
    public init(
        id: Int,
        userId: Int,
        contentId: Int,
        thumbNail: String, 
        title: String,
        body: String,
        createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.contentId = contentId
        self.thumbNail = thumbNail
        self.title = title
        self.body = body
        self.createdAt = createdAt
    }
}
