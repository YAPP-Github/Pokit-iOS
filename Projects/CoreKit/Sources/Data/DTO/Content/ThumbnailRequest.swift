//
//  ThumbnailRequest.swift
//  CoreKit
//
//  Created by 김도형 on 12/1/24.
//

import Foundation

public struct ThumbnailRequest: Encodable {
    private let thumbnail: String
    
    public init(thumbnail: String) {
        self.thumbnail = thumbnail
    }
}
