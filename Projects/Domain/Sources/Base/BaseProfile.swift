//
//  BaseProfile.swift
//  Domain
//
//  Created by 김민호 on 2/24/25.
//

import Util

public struct BaseProfile: Equatable, Identifiable, CategoryImage {
    public let id: Int
    public let imageURL: String
    
    public init(
        id: Int,
        imageURL: String
    ) {
        self.id = id
        self.imageURL = imageURL
    }
}
