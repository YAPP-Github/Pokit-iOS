//
//  SplashView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import DSKit

import ComposableArchitecture

@ViewAction(for: SplashFeature.self)
public struct SplashView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<SplashFeature>
    /// - Initializer
    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SplashView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    Spacer()
                    
                    Image(.logo(.pokit))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 72)
                        .foregroundStyle(.pokit(.icon(.inverseWh)))
                    
                    Spacer()
                }
                .padding(.top, 254)
                
                Spacer()
            }
            .background {
                Color
                    .pokit(.bg(.brand))
                    .ignoresSafeArea()
            }
            .alert($store.scope(state: \.alert, action: \.scope.alert))
            .onAppear { send(.onAppear) }
        }
    }
}
//MARK: - Configure View
extension SplashView {
    
}
//MARK: - Preview
#Preview {
    SplashView(
        store: Store(
            initialState: .init(),
            reducer: { SplashFeature() }
        )
    )
}


