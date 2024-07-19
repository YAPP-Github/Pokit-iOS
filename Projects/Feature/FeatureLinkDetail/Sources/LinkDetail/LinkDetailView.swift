//
//  LinkDetailView.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: LinkDetailFeature.self)
public struct LinkDetailView: View {
    /// - Properties
    public var store: StoreOf<LinkDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<LinkDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LinkDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension LinkDetailView {
    
}
//MARK: - Preview
#Preview {
    LinkDetailView(
        store: Store(
            initialState: .init(
                link: LinkDetailMock(
                    title: "자연 친화적인 라이프스타일을 위한 환경 보호 방법",
                    url: "https://www.youtube.com/watch?v=xSTwqKUyM8k",
                    createdAt: .now,
                    memo: "건강과 지속 가능성을 추구",
                    pokit: "아티클",
                    isRemind: false,
                    isFavorite: false
                )
            ),
            reducer: { LinkDetailFeature() }
        )
    )
}


