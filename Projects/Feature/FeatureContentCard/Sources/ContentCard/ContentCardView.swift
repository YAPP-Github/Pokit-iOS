//
//  LinkCardView.swift
//  Feature
//
//  Created by 김도형 on 11/17/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit

@ViewAction(for: ContentCardFeature.self)
public struct ContentCardView: View {
    /// - Properties
    public var store: StoreOf<ContentCardFeature>
    private let isFirst: Bool
    private let isLast: Bool
    
    /// - Initializer
    public init(
        store: StoreOf<ContentCardFeature>,
        isFirst: Bool = false,
        isLast: Bool = false
    ) {
        self.store = store
        self.isFirst = isFirst
        self.isLast = isLast
    }
}
//MARK: - View
public extension ContentCardView {
    var body: some View {
        WithPerceptionTracking {
            PokitLinkCard(
                link: store.content,
                action: { send(.컨텐츠_항목_눌렀을때) },
                kebabAction: { send(.컨텐츠_항목_케밥_버튼_눌렀을때) },
                fetchMetaData: { send(.메타데이터_조회) }
            )
            .divider(isFirst: isFirst, isLast: isLast)
        }
    }
}
//MARK: - Configure View
private extension ContentCardView {
    
}
//MARK: - Preview
#Preview {
    ContentCardView(
        store: Store(
            initialState: .init(content: .init(
                id: 1,
                categoryName: "미분류",
                categoryId: 992 ,
                title: "youtube",
                thumbNail: "https://i.ytimg.com/vi/NnOC4_kH0ok/hqdefault.jpg?sqp=-oaymwEjCNACELwBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDN6u6mTjbaVmRZ4biJS_aDq4uvAQ",
                data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
                domain: "신서유기",
                createdAt: "2024.08.08",
                isRead: false
            )),
            reducer: { ContentCardFeature() }
        )
    )
}


