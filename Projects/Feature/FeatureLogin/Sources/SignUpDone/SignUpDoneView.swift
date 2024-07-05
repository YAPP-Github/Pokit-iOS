//
//  SignUpDoneView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

public struct SignUpDoneView: View {
    /// - Properties
    private let store: StoreOf<SignUpDoneFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpDoneFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SignUpDoneView {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension SignUpDoneView {
    
}
//MARK: - Preview
#Preview {
    SignUpDoneView(
        store: Store(
            initialState: .init(),
            reducer: { SignUpDoneFeature() }
        )
    )
}


