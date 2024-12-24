//
//  PokitLinkEditView.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokitLinkEditFeature.self)
public struct PokitLinkEditView: View {
    /// - Properties
    public var store: StoreOf<PokitLinkEditFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitLinkEditFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitLinkEditView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension PokitLinkEditView {
    
}
//MARK: - Preview
#Preview {
    PokitLinkEditView(
        store: Store(
            initialState: .init(),
            reducer: { PokitLinkEditFeature() }
        )
    )
}


