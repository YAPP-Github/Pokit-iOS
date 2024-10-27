//
//  RemindSplitView.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import SwiftUI

import ComposableArchitecture
import FeatureRemind
import FeatureContentList
import FeatureSetting
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureCategorySharing
import DSKit
import Util

@ViewAction(for: RemindSplitFeature.self)
public struct RemindSplitView: View {
    /// - Properties
    @Perception.Bindable
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
            NavigationSplitView(columnVisibility: $store.columnVisibility) {
                ContentSettingView(store: store.scope(state: \.링크추가, action: \.링크추가))
                    .toolbarBackground(.hidden, for: .navigationBar)
            } content: {
                RemindView(store: store.scope(state: \.리마인드, action: \.리마인드))
                    .pokitNavigationBar { remindNavigationBar }
                    .toolbarBackground(.hidden, for: .navigationBar)
            } detail: {
                detail
            }
            .sheet(
                item: $store.scope(
                    state: \.포킷추가및수정,
                    action: \.포킷추가및수정
                )
            ) { store in
                PokitCategorySettingView(store: store)
                    .pokitPresentationBackground()
                    .pokitPresentationCornerRadius()
            }
            .sheet(
                item: $store.scope(
                    state: \.링크상세,
                    action: \.링크상세
                )
            ) { store in
                ContentDetailView(store: store)
                    .pokitPresentationBackground()
                    .pokitPresentationCornerRadius()
            }
            .sheet(
                item: $store.scope(
                    state: \.알림함,
                    action: \.알림함
                )
            ) { store in
                PokitAlertBoxView(store: store)
                    .pokitPresentationBackground()
                    .pokitPresentationCornerRadius()
            }
            .sheet(
                item: $store.scope(
                    state: \.링크수정,
                    action: \.링크수정
                )
            ) { store in
                ContentSettingView(store: store)
                    .pokitPresentationBackground()
                    .pokitPresentationCornerRadius()
            }
        }
    }
}
//MARK: - Configure View
private extension RemindSplitView {
    var detail: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ContentListView(store: store.scope(state: \.링크목록, action: \.링크목록))
        } destination: { path in
            WithPerceptionTracking {
                switch path.case {
                case let .검색(store):
                    PokitSearchView(store: store)
                }
            }
        }
    }
    
    var remindNavigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                Text("Remind")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(.pokit(.text(.brand)))
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
            }
        }
        .padding(.vertical, 8)
    }
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


