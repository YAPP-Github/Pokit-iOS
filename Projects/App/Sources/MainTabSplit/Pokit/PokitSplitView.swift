//
//  PokitSplitView.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import SwiftUI

import ComposableArchitecture
import FeaturePokit
import FeatureRemind
import FeatureSetting
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureCategoryDetail
import FeatureContentList
import FeatureCategorySharing

@ViewAction(for: PokitSplitFeature.self)
public struct PokitSplitView: View {
    /// - Properties
    public var store: StoreOf<PokitSplitFeature>
    
    /// - Initializer
    public init(store: StoreOf<PokitSplitFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitSplitView {
    var body: some View {
        WithPerceptionTracking {
            NavigationSplitView(columnVisibility: .constant(.all)) {
                PokitRootView(store: store.scope(state: \.포킷, action: \.포킷))
                    .toolbar(.hidden, for: .navigationBar)
            } detail: {
                detail
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSplitView {
    var detail: some View {
        HStack(spacing: 0) {
            if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                CategoryDetailView(store: store)
            } else {
                Spacer()
            }
            
            ContentSettingView(store: store.scope(state: \.링크추가및수정, action: \.링크추가및수정))
                .frame(width: 375)
        }
    }
}
//MARK: - Preview
#Preview {
    PokitSplitView(
        store: Store(
            initialState: .init(),
            reducer: { PokitSplitFeature() }
        )
    )
}


