//
//  BaseCategoryDetail.swift
//  Domain
//
//  Created by 김도형 on 8/8/24.
//

import Foundation

import CoreKit

public struct BaseCategory: Equatable {
    public let categoryId: Int
    public let categoryName: String
    public let categoryImage: BaseCategoryImage
    public let alertEnabled: Bool
    
    public init(
        categoryId: Int,
        categoryName: String,
        categoryImage: BaseCategoryImage,
        alertEnabled: Bool = true
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryImage = categoryImage
        self.alertEnabled = alertEnabled
    }
}
