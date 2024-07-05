//
//  AgreeToTermsView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

public struct AgreeToTermsView: View {
    /// - Properties
    private let store: StoreOf<AgreeToTermsFeature>
    /// - Initializer
    public init(store: StoreOf<AgreeToTermsFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension AgreeToTermsView {
    var body: some View {
        VStack {
            Text("Hello World!")
        }
    }
}
//MARK: - Configure View
extension AgreeToTermsView {
    
}
//MARK: - Preview
#Preview {
    AgreeToTermsView(
        store: Store(
            initialState: .init(),
            reducer: { AgreeToTermsFeature() }
        )
    )
}


