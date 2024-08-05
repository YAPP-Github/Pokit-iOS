//
//  BaseCategoryImage.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

import Util

public struct BaseCategoryImage: Equatable, CategoryImage {
    public var imageId: Int
    public var imageURL: String
    
    public init(
        imageId: Int,
        imageURL: String
    ) {
        self.imageId = imageId
        self.imageURL = imageURL
    }
}
