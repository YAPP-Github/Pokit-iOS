//
//  CategoryKaKaoShareModel.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct CategoryKaKaoShareModel {
    public enum ShareType: String {
        case 공유 = "share"
        case 초대 = "invite"
    }
    
    let shareType: ShareType
    let categoryName: String
    let categoryId: Int
    let imageURL: String
    
    public init(
        shareType: ShareType,
        categoryName: String,
        categoryId: Int,
        imageURL: String
    ) {
        self.shareType = shareType
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.imageURL = imageURL
    }
}
