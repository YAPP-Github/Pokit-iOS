//
//  PokitCategorySettingView.swift
//  Feature
//
//  Created by 김민호 on 7/25/24.

import SwiftUI

import ComposableArchitecture

@ViewAction(for: PokitCategorySettingFeature.self)
public struct PokitCategorySettingView: View {
    /// - Properties
    public var store: StoreOf<PokitCategorySettingFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitCategorySettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitCategorySettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitCategorySettingView {
    
}
//MARK: - Preview
#Preview {
    PokitCategorySettingView(
        store: Store(
            initialState: .init(),
            reducer: { PokitCategorySettingFeature() }
        )
    )
}


