//
//  MainTabView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import SwiftUI

public struct MainTabView: View {
    /// - Properties
    private let store: StoreOf<MainTabFeature>
    /// - Initializer
    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension MainTabView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Tabbar")
            }
        }
    }
}
//MARK: - Configure View
extension MainTabView {
    
}
//MARK: - Preview
#Preview {
    MainTabView(
        store: Store(
            initialState: .init(),
            reducer: { MainTabFeature() }
        )
    )
}


