//
//  PokitSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture

@ViewAction(for: PokitSettingFeature.self)
public struct PokitSettingView: View {
    /// - Properties
    public var store: StoreOf<PokitSettingFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSettingView {
    
}
//MARK: - Preview
#Preview {
    PokitSettingView(
        store: Store(
            initialState: .init(),
            reducer: { PokitSettingFeature() }
        )
    )
}


