//
//  RemindClient.swift
//  CoreKit
//
//  Created by 김도형 on 8/8/24.
//

import Foundation

import Dependencies
import Moya

public struct RemindClient {
    public var 오늘의_리마인드_조회: @Sendable ()
    async throws -> [ContentBaseResponse]
    public var 읽지않음_컨텐츠_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
    public var 즐겨찾기_링크모음_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
}

extension RemindClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<RemindEndpoint>.build()
        
        return .init(
            오늘의_리마인드_조회: {
                try await provider.request(.오늘의_리마인드_조회)
            },
            읽지않음_컨텐츠_조회: { model in
                try await provider.request(.읽지않음_컨텐츠_조회(model: model))
            },
            즐겨찾기_링크모음_조회: { model in
                try await provider.request(.즐겨찾기_링크모음_조회(model: model))
            }
        )
    }()
    
    public static let previewValue: Self = {
        .init(
            오늘의_리마인드_조회: { [.mock(id: 0), .mock(id: 1), .mock(id: 2)]},
            읽지않음_컨텐츠_조회: { _ in .mock },
            즐겨찾기_링크모음_조회: { _ in .mock }
        )
    }()
}

extension DependencyValues {
    public var remindClient: RemindClient {
        get { self[RemindClient.self] }
        set { self[RemindClient.self] = newValue }
    }
}
