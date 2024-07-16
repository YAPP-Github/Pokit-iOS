//
//  PokitRootView.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import SwiftUI

import ComposableArchitecture
import DSKit

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
            NavigationStack {
                VStack {
                    Text("hello")
                }
                .toolbar { self.navigationBar }
            }
        }
    }
}
//MARK: - Configure View
private extension PokitRootView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Pokit")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.pokit(.text(.brand)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { send(.searchButtonTapped) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { send(.alertButtonTapped) }
                )
                PokitToolbarButton(
                    .icon(.setup), 
                    action: { send(.settingButtonTapped) }
                )
            }
        }
    }
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


