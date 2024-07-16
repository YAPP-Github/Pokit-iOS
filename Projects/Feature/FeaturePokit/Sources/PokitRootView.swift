//
//  PokitRootView.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokitRootFeature.self)
public struct PokitRootView: View {
    /// - Properties
    public var store: StoreOf<PokitRootFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitRootView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitRootView {
    
}
//MARK: - Preview
#Preview {
    PokitRootView(
        store: Store(
            initialState: .init(),
            reducer: { PokitRootFeature() }
        )
    )
}


