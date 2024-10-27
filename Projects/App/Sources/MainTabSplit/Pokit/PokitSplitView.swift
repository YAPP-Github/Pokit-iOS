//
//  PokitSplitView.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import SwiftUI

import ComposableArchitecture
import FeaturePokit
import FeatureSetting
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureCategoryDetail
import FeatureContentList
import FeatureCategorySharing
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
                ContentSettingView(store: store.scope(state: \.링크추가, action: \.링크추가))
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTitle("")
            } content: {
                PokitRootView(store: store.scope(state: \.포킷, action: \.포킷))
                    .pokitNavigationBar { pokitNavigationBar }
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTitle("")
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
                    state: \.설정,
                    action: \.설정
                )
            ) { store in
                PokitSettingView(store: store)
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
            .sheet(item: $store.error) { error in
                PokitAlert(
                    error?.title ?? "에러",
                    message: error?.message ?? "메세지",
                    confirmText: "확인",
                    action: { send(.경고_확인버튼_클릭) }
                )
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSplitView {
    var detail: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                if let store = store.scope(state: \.카테고리상세, action: \.카테고리상세) {
                    CategoryDetailView(store: store)
                } else {
                    VStack {
                        Spacer()
                        
                        PokitCaution(
                            image: .empty,
                            titleKey: "선택된 포킷이 없어요!",
                            message: "포킷 화면에서 포킷을 선택해주세요"
                        )
                        
                        Spacer()
                    }
                    .background(.pokit(.bg(.base)))
                    .ignoresSafeArea()
                }
            }
        } destination: { path in
            WithPerceptionTracking {
                switch path.case {
                case let .검색(store):
                    PokitSearchView(store: store)
                }
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
                PokitToolbarButton(
                    .icon(.edit),
                    action: { send(.포킷추가_버튼_눌렀을때) }
                )
                .pokitBlurReplaceTransition(.pokitDissolve)
                
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


