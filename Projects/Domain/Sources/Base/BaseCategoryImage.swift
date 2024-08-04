//
//  BaseCategoryImage.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct BaseCategoryImage: Equatable {
    public let imageId: Int
    public let imageURL: String
    
    public init(
        imageId: Int,
        imageURL: String
    ) {
        self.imageId = imageId
        self.imageURL = imageURL
    }
}
