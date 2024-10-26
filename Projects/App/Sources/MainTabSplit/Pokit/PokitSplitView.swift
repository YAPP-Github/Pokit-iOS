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
import CoreKit
import DSKit
import Util

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
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTitle("")
            } content: {
                PokitRootView(store: store.scope(state: \.포킷, action: \.포킷))
                    .pokitNavigationBar { pokitNavigationBar }
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTitle("")
            } detail: {
                if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                    CategoryDetailView(store: store)
                } else {
                    Color.pokit(.bg(.base))
                        .ignoresSafeArea()
                }
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSplitView {
    var detail: some View {
        HStack(spacing: 0) {
            PokitRootView(store: store.scope(state: \.포킷, action: \.포킷))
                .pokitNavigationBar { pokitNavigationBar }
                .frame(width: 400)
            
            if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                CategoryDetailView(store: store)
            } else {
                Spacer()
            }
        }
    }
    
    var pokitNavigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                Image(.logo(.pokit))
                    .resizable()
                    .frame(width: 104, height: 32)
                    .foregroundStyle(.pokit(.icon(.brand)))
            }
            
            PokitHeaderItems(placement: .trailing) {
                if store.columnVisibility == .doubleColumn {
                    PokitToolbarButton(
                        .icon(.edit),
                        action: { send(.링크추가_버튼_눌렀을때) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
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


