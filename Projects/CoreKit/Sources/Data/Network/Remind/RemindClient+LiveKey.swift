//
//  RemindClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import Moya

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
            },
            읽지않음_컨텐츠_개수_조회: {
                try await provider.request(.읽지않음_컨텐츠_개수_조회)
            },
            즐겨찾기_컨텐츠_개수_조회: {
                try await provider.request(.즐겨찾기_컨텐츠_개수_조회)
            }
        )
    }()
}
