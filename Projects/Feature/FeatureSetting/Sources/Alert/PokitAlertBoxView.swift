//
//  PokitAlertBoxView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture

@ViewAction(for: PokitAlertBoxFeature.self)
public struct PokitAlertBoxView: View {
    /// - Properties
    public var store: StoreOf<PokitAlertBoxFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitAlertBoxFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitAlertBoxView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitAlertBoxView {
    
}
//MARK: - Preview
#Preview {
    PokitAlertBoxView(
        store: Store(
            initialState: .init(),
            reducer: { PokitAlertBoxFeature() }
        )
    )
}


