//
//  LinkListView.swift
//  Feature
//
//  Created by 김도형 on 8/2/24.

import SwiftUI

import ComposableArchitecture
import FeatureContentCard
import DSKit

@ViewAction(for: ContentListFeature.self)
public struct ContentListView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<ContentListFeature>
    
    /// - Initializer
    public init(store: StoreOf<ContentListFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension ContentListView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                listHeader
                    .padding(.horizontal, 20)
                
                list
            }
            .padding(.top, 12)
            .pokitNavigationBar { toolbar }
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $store.bottomSheetItem) { content in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: {
                        send(.bottomSheet(delegate: $0, content: content))
                    }
                )
            }
            .sheet(item: $store.shareSheetItem) { content in
                if let shareURL = URL(string: content.data) {
                    PokitShareSheet(
                        items: [shareURL],
                        completion: { send(.링크_공유시트_해제) }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(item: $store.alertItem) { content in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제",
                    action: { send(.컨텐츠_삭제_눌렀을때(content: content)) },
                    cancelAction: { send(.경고시트_해제) }
                )
            }
            .task { await send(.뷰가_나타났을때, animation: .pokitDissolve).finish() }
        }
    }
}
//MARK: - Configure View
private extension ContentListView {
    var listHeader: some View {
        HStack {
            Text("링크 \(store.contentCount)개")
                .pokitFont(.detail1)
                .foregroundStyle(.pokit(.text(.secondary)))
                .contentTransition(.numericText())
            
            Spacer()
            
            PokitIconLTextLink(
                store.isListDescending ? "최신순" : "오래된순",
                icon: .icon(.align),
                action: { send(.정렬_버튼_눌렀을때) }
            )
            .contentTransition(.numericText())
        }
    }
    
    var list: some View {
        Group {
            if !store.isLoading {
                if store.contents.isEmpty {
                    PokitCaution(type: .즐겨찾기_링크없음)
                    .padding(.top, 100)
                    
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(
                                store.scope(state: \.contents, action: \.contents)
                            ) { store in
                                let isFirst = store.state.id == self.store.contents.first?.id
                                let isLast = store.state.id == self.store.contents.last?.id
                                
                                ContentCardView(
                                    store: store,
                                    isFirst: isFirst,
                                    isLast: isLast
                                )
                            }
                            
                            if store.hasNext {
                                PokitLoading()
                                    .task { await send(.pagenation).finish() }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 36)
                    }
                }
            } else {
                PokitLoading()
            }
        }
    }
    
    var toolbar: some View {
        PokitHeader(title: store.contentType.title) {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    send(.dismiss)
                }
            }
        }
        .padding(.top, 8)
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        ContentListView(
            store: Store(
                initialState: .init(contentType: .favorite),
                reducer: { ContentListFeature() }
            )
        )
    }
}


