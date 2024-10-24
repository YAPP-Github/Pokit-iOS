//
//  RemindSplitView.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: RemindSplitFeature.self)
public struct RemindSplitView: View {
    /// - Properties
    public var store: StoreOf<RemindSplitFeature>
    
    /// - Initializer
    public init(store: StoreOf<RemindSplitFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension RemindSplitView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension RemindSplitView {
    
}
//MARK: - Preview
#Preview {
    RemindSplitView(
        store: Store(
            initialState: .init(),
            reducer: { RemindSplitFeature() }
        )
    )
}


