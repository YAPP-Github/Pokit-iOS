//
//  PokitSearchView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture

@ViewAction(for: PokitSearchFeature.self)
public struct PokitSearchView: View {
    /// - Properties
    public var store: StoreOf<PokitSearchFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitSearchFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitSearchView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSearchView {
    
}
//MARK: - Preview
#Preview {
    PokitSearchView(
        store: Store(
            initialState: .init(),
            reducer: { PokitSearchFeature() }
        )
    )
}


