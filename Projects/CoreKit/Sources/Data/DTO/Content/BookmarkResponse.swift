//
//  BookmarkResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 즐겨찾기 API Response
public struct BookmarkResponse: Decodable {
    let contentId: Int
}

extension BookmarkResponse {
    public static var mock: Self = Self (contentId: 555107)
}
