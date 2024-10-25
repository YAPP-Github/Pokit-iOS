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
import DSKit

@ViewAction(for: PokitSplitFeature.self)
public struct PokitSplitView: View {
    /// - Properties
    @Perception.Bindable
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
            NavigationSplitView(columnVisibility: $store.columnVisibility) {
                ContentSettingView(store: store.scope(state: \.링크추가및수정, action: \.링크추가및수정))
            } content: {
                PokitRootView(store: store.scope(state: \.포킷, action: \.포킷))
                    .pokitNavigationBar { pokitNavigationBar }
            } detail: {
                if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                    CategoryDetailView(store: store)
                }
            }
            
        }
    }
}
//MARK: - Configure View
private extension PokitSplitView {
    var pokitNavigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                Image(.logo(.pokit))
                    .resizable()
                    .frame(width: 104, height: 32)
                    .foregroundStyle(.pokit(.icon(.brand)))
            }
            
            PokitHeaderItems(placement: .trailing) {
                PokitToolbarButton(
                    .icon(.search),
                    action: { send(.검색_버튼_눌렀을때) }
                )
                PokitToolbarButton(
                    .icon(.bell),
                    action: { send(.알람_버튼_눌렀을때) }
                )
                PokitToolbarButton(
                    .icon(.setup),
                    action: { send(.설정_버튼_눌렀을때) }
                )
            }
        }
        .padding(.vertical, 8)
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


