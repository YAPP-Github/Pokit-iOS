//
//  ContentClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies
import Moya

extension ContentClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<ContentEndpoint>.build()
        
        return Self(
            컨텐츠_삭제: { id in
                try await provider.requestNoBody(.컨텐츠_삭제(contentId: id))
            },
            컨텐츠_상세_조회: { id in
                try await provider.request(.컨텐츠_상세_조회(contentId: id))
            },
            컨텐츠_수정: { id, model in
                try await provider.request(.컨텐츠_수정(contentId: id, model: model))
            },
            컨텐츠_추가: { model in
                try await provider.request(.컨텐츠_추가(model: model))
            },
            즐겨찾기: { id in
                try await provider.request(.즐겨찾기(contentId: id))
            },
            즐겨찾기_취소: { id in
                try await provider.requestNoBody(.즐겨찾기_취소(contentId: id))
            },
            카테고리_내_컨텐츠_목록_조회: { id, pageable, condition in
                try await provider.request(
                    .카태고리_내_컨텐츠_목록_조회(
                        contentId: id,
                        pageable: pageable,
                        condition: condition
                    )
                )
            },
            미분류_카테고리_컨텐츠_조회: { model in
                try await provider.request(.미분류_카테고리_컨텐츠_조회(model: model))
            },
            컨텐츠_검색: { pageable, condition in
                try await provider.request(
                    .컨텐츠_검색(
                        pageable: pageable,
                        condition: condition
                    )
                )
            },
            썸네일_수정: { id, model in
                try await provider.requestNoBody(
                    .썸네일_수정(contentId: id, model: model)
                )
            }
        )
    }()
}
