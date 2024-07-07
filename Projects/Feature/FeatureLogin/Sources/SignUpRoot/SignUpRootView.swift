//
//  SignUpNavigationStackView.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import SwiftUI
import Perception
import DSKit
import CoreKit

public struct SignUpRootView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<SignUpRootFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpRootFeature>) {
        self.store = store
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.backgroundColor = UIColor(.pokit(.bg(.base)))
        barAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().compactAppearance = barAppearance
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


