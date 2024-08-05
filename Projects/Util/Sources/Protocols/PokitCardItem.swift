//
//  PokitCardItem.swift
//  Util
//
//  Created by 김도형 on 7/11/24.
//

import Foundation

public protocol PokitCardItem {
    associatedtype Thumbnail: CategoryImage
    
    var categoryName: String { get }
    var contentCount: Int { get }
    var categoryImage: Thumbnail { get }
}

public protocol CategoryImage {
    var id: Int { get }
    var imageURL: String { get }
}
