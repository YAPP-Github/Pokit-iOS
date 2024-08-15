//
//  KakaoShareModel.swift
//  CoreKit
//
//  Created by 김도형 on 8/15/24.
//

import Foundation

public struct KakaoShareModel {
    let title: String
    let description: String
    let imageURL: String
    let userId: Int
    let contentId: Int
    
    public init(
        title: String,
        description: String,
        imageURL: String,
        userId: Int,
        contentId: Int
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.userId = userId
        self.contentId = contentId
    }
}
