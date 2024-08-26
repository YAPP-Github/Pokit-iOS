//
//  LinkDetail.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct ContentDetail: Equatable {
    // - MARK: Response
    /// 콘텐츠(링크) 상세
    public var content: BaseContentDetail?
    // - MARK: Request
    /// 조회할 콘텐츠 id
    public let contentId: Int?
    
    public init(
        content: BaseContentDetail?,
        contentId: Int?
    ) {
        self.content = content
        self.contentId = contentId
    }
}
