//
//  PokitRootView.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import SwiftUI

import ComposableArchitecture
import FeatureContentCard
import Domain
import DSKit

@ViewAction(for: PokitRootFeature.self)
public struct PokitRootView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<PokitRootFeature>
    private let column = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 0)
    ]

    /// - Initializer
    public init(store: StoreOf<PokitRootFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitRootView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                self.filterHeader
                self.cardScrollView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $store.isKebobSheetPresented) {
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: { store.send(.scope(.bottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: store.folderType == .folder(.포킷)
                    ? .포킷삭제
                    : .링크삭제,
                    delegateSend: { store.send(.scope(.deleteBottomSheet($0)), animation: .pokitSpring) }
                )
            }
            .fullScreenCover(
                item: $store.scope(
                    state: \.linkEdit,
                    action: \.scope.linkEdit
                )
            ) { store in
                WithPerceptionTracking {
                    PokitLinkEditView(store: store)
                }
            }
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitRootView {
    var filterHeader: some View {
        HStack(spacing: 8) {
            PokitIconLButton(
                "포킷",
                .icon(.folderLine),
                state: store.folderType == .folder(.포킷)
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.필터_버튼_눌렀을때(.포킷)) }
            )

            PokitIconLButton(
                "미분류",
                .icon(.info),
                state: store.folderType == .folder(.미분류)
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.필터_버튼_눌렀을때(.미분류)) }
            )

            Spacer()
            
            /// 카테고리가 있을 때 `정렬` 추가
            if store.folderType == .folder(.포킷) && store.categories != nil {
                PokitIconLTextLink(
                    store.sortType == .sort(.최신순) ?
                    "최신순" : store.folderType == .folder(.포킷) ? "이름순" : "오래된순",
                    icon: .icon(.align),
                    action: { send(.분류_버튼_눌렀을때) }
                )
                .contentTransition(.numericText())
            }
            /// 미분류 링크가 있을 때 `편집하기` 추가
            if store.folderType == .folder(.미분류) && !store.contents.isEmpty {
                PokitTextLink(
                    "편집하기",
                    color: .bg(.brand),
                    action: { send(.편집하기_버튼_눌렀을때) }
                )
            }
        }
    }

    var cardScrollView: some View {
        Group {
            if store.folderType == .folder(.포킷) {
                pokitView
                    .padding(.top, 20)
            } else {
                unclassifiedView
            }
        }
        .scrollIndicators(.hidden)
        .animation(.pokitDissolve, value: store.folderType)
    }

    @ViewBuilder
    var pokitView: some View {
        if let categories = store.categories {
            if categories.isEmpty {
                PokitCaution(
                    type: .카테고리없음,
                    action: { send(.포킷추가_버튼_눌렀을때) }
                )
            } else {
                pokitList(categories)
            }
        } else {
            PokitLoading()
        }
    }

    @ViewBuilder
    func pokitList(_ categories: IdentifiedArrayOf<BaseCategoryItem>) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                LazyVGrid(columns: column, spacing: 12) {
                    ForEach(categories, id: \.id) { item in
                        if item.isFavorite {
                            PokitFavoriteCard(
                                linkCount: item.contentCount,
                                action: { send(.카테고리_눌렀을때(item)) }
                            )
                        }
                        else {
                            PokitCard(
                                category: item,
                                action: { send(.카테고리_눌렀을때(item)) },
                                kebabAction: { send(.케밥_버튼_눌렀을때(item)) }
                            )
                        }
                    }
                }

                if store.hasNext {
                    PokitLoading()
                        .onAppear { send(.페이지_로딩중일때) }
                }
            }
            .padding(.bottom, 150)
        }
    }

    @ViewBuilder
    var unclassifiedView: some View {
        if !store.isLoading {
            if store.contents.isEmpty {
                PokitCaution(
                    type: .미분류_링크없음,
                    action: { send(.링크추가_버튼_눌렀을때) }
                )
            } else {
                unclassifiedList
                    .padding(.top, 20)
            }
        } else {
            PokitLoading()
        }
    }

    var unclassifiedList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(
                    Array(store.scope(state: \.contents, action: \.contents))
                ) { store in
                    let isFirst = store.state.id == self.store.contents.first?.id
                    let isLast = store.state.id == self.store.contents.last?.id
                    
                    ContentCardView(
                        store: store,
                        type: .linkList,
                        isFirst: isFirst,
                        isLast: isLast
                    )
                }

                if store.unclassifiedHasNext {
                    PokitLoading()
                        .onAppear(perform: { send(.페이지_로딩중일때) })
                }
            }
            .padding(.bottom, 150)
        }
    }
}

//MARK: - Preview
#Preview {
    Group {
        PokitRootView(
            store: Store(
                initialState: .init(),
                reducer: { PokitRootFeature() }
            )
        )
    }
}


