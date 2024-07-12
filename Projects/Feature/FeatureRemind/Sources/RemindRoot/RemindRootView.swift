//
//  RemindRootView.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import ComposableArchitecture
import SwiftUI

import DSKit

public struct RemindRootView: View {
    /// - Properties
    private let store: StoreOf<RemindRootFeature>
    /// - Initializer
    public init(store: StoreOf<RemindRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RemindRootView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
extension RemindView {
    
}
//MARK: - Preview
#Preview {
    RemindRootView(
        store: Store(
            initialState: .init(),
            reducer: { RemindRootFeature() }
        )
    )
}


