//
//  BaseCategory.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct BaseCategory: Identifiable, Equatable {
    public let id: Int
    public let userId: Int
    public let categoryName: String
    public let categoryImage: Self.Image
    
    public struct Image: Equatable {
        public let imageId: Int
        public let imageURL: String
    }
}
