//
//  RootView.swift
//  App
//
//  Created by 김민호 on 7/5/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureLogin
import DSKit

public struct RootView: View {
    /// - Properties
    private let store: StoreOf<RootFeature>
    /// - Initalizer
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
}
//MARK: - View
extension RootView {
    public var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .intro:
                    if let store = store.scope(state: \.intro, action: \.intro) {
                        IntroView(store: store)
                    }
                case .mainTab:
                    if let store = store.scope(state: \.mainTab, action: \.mainTab) {
                        MainTabView(store: store)
                    }
                }
            }
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .animation(.smooth, value: store.mainTab)
        }
    }
}
//MARK: - Configure View
extension RootView {}
//MARK: - Preview
#Preview {
    RootView(
        store: Store(
            initialState: .init(),
            reducer: { RootFeature() }
        )
    )
}
