//
//  LoginView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
    /// - Properties
    private let store: StoreOf<LoginFeature>
    /// - Initializer
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension LoginView {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension LoginView {
    
}
//MARK: - Preview
#Preview {
    LoginView(
        store: Store(
            initialState: .init(),
            reducer: { LoginFeature() }
        )
    )
}


