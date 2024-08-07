//
//  CategoryEditResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/4/24.
//

import Foundation

import CoreKit

public extension CategoryImageResponse {
    func toDomain() -> BaseCategoryImage {
        return .init(imageId: self.imageId, imageURL: self.imageUrl)
    }
}
