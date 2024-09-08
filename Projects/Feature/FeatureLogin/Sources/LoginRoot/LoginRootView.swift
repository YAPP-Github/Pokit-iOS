//
//  LoginRootView.swift
//  Feature
//
//  Created by 김도형 on 9/7/24.

import SwiftUI

import ComposableArchitecture

public struct LoginRootView: View {
    /// - Properties
    public let store: StoreOf<LoginRootFeature>
    
    /// - Initializer
    public init(store: StoreOf<LoginRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LoginRootView {
    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .login:
                    if let store = store.scope(state: \.login, action: \.login) {
                        LoginView(store: store)
                    }
                case .signUpDone:
                    if let store = store.scope(state: \.signUpDone, action: \.signUpDone) {
                        SignUpDoneView(store: store)
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
private extension LoginRootView {
    
}
//MARK: - Preview
#Preview {
    LoginRootView(
        store: Store(
            initialState: .login(.init()),
            reducer: { LoginRootFeature() }
        )
    )
}


