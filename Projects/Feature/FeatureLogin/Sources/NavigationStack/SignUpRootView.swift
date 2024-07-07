//
//  SignUpNavigationStackView.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import SwiftUI
import Perception

public struct SignUpRootView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<SignUpRootFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SignUpRootView {
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            LoginView(store: store.scope(state: \.login, action: \.login))
        } destination: { path in
            switch path.case {
            case .agreeToTerms(let store):
                AgreeToTermsView(store: store)
            case .registerNickname(let store):
                RegisterNicknameView(store: store)
            case .selecteField(let store):
                SelectFieldView(store: store)
            case .signUpDone(let store):
                SignUpDoneView(store: store)
            }
        }
    }
}
//MARK: - Configure View
extension SignUpRootView {
    
}
//MARK: - Preview
#Preview {
    SignUpRootView(
        store: Store(
            initialState: .init(),
            reducer: { SignUpRootFeature() }
        )
    )
}


