//
//  DemoView.swift
//  Feature
//
//  Created by 김도형 on 12/24/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: DemoFeature.self)
public struct DemoView<T: View>: View {
    /// - Properties
    public let store: StoreOf<DemoFeature>
    
    @ViewBuilder
    private let mainView: T
    
    /// - Initializer
    public init(
        store: StoreOf<DemoFeature>,
        @ViewBuilder mainView: () -> T
    ) {
        self.store = store
        self.mainView = mainView()
    }
}
//MARK: - View
public extension DemoView {
    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .intro:
                    if let store = store.scope(state: \.intro, action: \.intro) {
                        IntroView(store: store)
                    }
                case .main:
                    mainView
                }
            }
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .animation(.smooth, value: store)
        }
    }
}
//MARK: - Configure View
private extension DemoView {
    
}
//MARK: - Preview
#Preview {
    DemoView(store: Store(
        initialState: .init(),
        reducer: { DemoFeature() }
    )) {
        
    }
}


