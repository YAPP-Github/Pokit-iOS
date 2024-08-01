//
//  LinkDetail.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct LinkDetail {
    /// - Response
    public let contentId: Int
    public let categoryName: String
    public let title: String
    public let data: String
    public let createdAt: Date
    public let favorites: Bool
}
