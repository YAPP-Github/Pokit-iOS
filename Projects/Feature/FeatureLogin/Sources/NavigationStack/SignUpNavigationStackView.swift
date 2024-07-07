//
//  SignUpNavigationStackView.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import SwiftUI
import Perception

public struct SignUpNavigationStackView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<SignUpNavigationStackFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpNavigationStackFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SignUpNavigationStackView {
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
extension SignUpNavigationStackView {
    
}
//MARK: - Preview
#Preview {
    SignUpNavigationStackView(
        store: Store(
            initialState: .init(),
            reducer: { SignUpNavigationStackFeature() }
        )
    )
}


