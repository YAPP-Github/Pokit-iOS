//
//  CategoryKaKaoShareModel.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct CategoryKaKaoShareModel {
    let categoryName: String
    let categoryId: Int
    let imageURL: String
    
    public init(
        categoryName: String,
        categoryId: Int,
        imageURL: String
    ) {
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.imageURL = imageURL
    }
}
