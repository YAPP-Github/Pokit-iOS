//
//  RemindClient.swift
//  CoreKit
//
//  Created by 김도형 on 8/8/24.
//

import DependenciesMacros

@DependencyClient
public struct RemindClient {
    public var 오늘의_리마인드_조회: @Sendable ()
    async throws -> [ContentBaseResponse]
    public var 읽지않음_컨텐츠_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
    public var 즐겨찾기_링크모음_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
    public var 읽지않음_컨텐츠_개수_조회: @Sendable ()
    async throws -> UnreadCountResponse
    public var 즐겨찾기_컨텐츠_개수_조회: @Sendable ()
    async throws -> BookmarkCountResponse
        
}
