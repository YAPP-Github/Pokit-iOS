//
//  RootView.swift
//  App
//
//  Created by 김민호 on 7/5/24.
//

import SwiftUI

import ComposableArchitecture

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
        Text("Hello, World!")
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
