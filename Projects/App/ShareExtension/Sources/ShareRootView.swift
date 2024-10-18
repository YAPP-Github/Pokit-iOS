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
import FeatureCategorySetting
import DSKit

struct ShareRootView: View {
    /// - Properties
    @Perception.Bindable
    private var store: StoreOf<ShareRootFeature>
    
    init(store: StoreOf<ShareRootFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                if let store = store.scope(state: \.intro, action: \.intro) {
                    IntroView(store: store)
                } else if let store = store.scope(state: \.contentSetting, action: \.contentSetting) {
                    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                        ContentSettingView(store: store)
                    } destination: { path in
                        switch path.case {
                        case let .categorySetting(store):
                            PokitCategorySettingView(store: store)
                        }
                    }
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
