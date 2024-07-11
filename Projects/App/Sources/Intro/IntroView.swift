//
//  IntroView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture
import FeatureLogin

public struct IntroView: View {
    /// - Properties
    private let store: StoreOf<IntroFeature>
    /// - Initializer
    public init(store: StoreOf<IntroFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension IntroView {
    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .splash:
                    if let store = store.scope(state: \.splash, action: \.splash) {
                        SplashView(store: store)
                    }
                case .login:
                    if let store = store.scope(state: \.login, action: \.login) {
                        LoginRootView(store: store)
                    }
                    
                }
            }
        }
    }
}
//MARK: - Configure View
extension IntroView {
    
}
//MARK: - Preview
#Preview {
    IntroView(
        store: Store(
            initialState: .init(),
            reducer: { IntroFeature() }
        )
    )
}


