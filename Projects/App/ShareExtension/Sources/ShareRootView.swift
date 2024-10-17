//
//  ShareRootView.swift
//  ShareExtension
//
//  Created by 김도형 on 10/17/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureLogin
import FeatureContentSetting

struct ShareRootView: View {
    /// - Properties
    private let store: StoreOf<ShareRootFeature>
    
    init(store: StoreOf<ShareRootFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                if let store = store.scope(state: \.intro, action: \.intro) {
                    IntroView(store: store)
                } else if let store = store.scope(state: \.contentSetting, action: \.contentSetting) {
                    ContentSettingView(store: store)
                }
            }
        }
    }
}

#Preview {
    ShareRootView(
        store: Store(
            initialState: .init(),
            reducer: { ShareRootFeature() }
        )
    )
}
