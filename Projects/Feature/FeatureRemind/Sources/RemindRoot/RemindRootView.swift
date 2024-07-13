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
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.backgroundColor = UIColor(.pokit(.bg(.base)))
        barAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(.pokit(.text(.primary))),
            .font: DSKitFontFamily.Pretendard.medium.font(size: 18)
        ]
        
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().compactAppearance = barAppearance
    }
}
//MARK: - View
public extension RemindRootView {
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                RemindView(
                    store: .init(
                        initialState: .init(),
                        reducer: { RemindFeature() }
                    )
                )
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


