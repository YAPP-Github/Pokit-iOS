//
//  RegisterNicknameView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

public struct RegisterNicknameView: View {
    /// - Properties
    private let store: StoreOf<RegisterNicknameFeature>
    /// - Initializer
    public init(store: StoreOf<RegisterNicknameFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RegisterNicknameView {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension RegisterNicknameView {
    
}
//MARK: - Preview
#Preview {
    RegisterNicknameView(
        store: Store(
            initialState: .init(),
            reducer: { RegisterNicknameFeature() }
        )
    )
}


