//
//  PokitRootView.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import SwiftUI

import ComposableArchitecture
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
            .sheet(item: $store.shareSheetItem) { content in
                if let shareURL = URL(string: content.data) {
                    PokitShareSheet(
                        items: [shareURL],
                        completion: { send(.링크_공유_완료(completed: $0)) }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: store.folderType == .folder(.포킷)
                    ? .포킷삭제
                    : .링크삭제,
                    delegateSend: { store.send(.scope(.deleteBottomSheet($0)), animation: .pokitSpring) }
                )
            }
            .task { await send(.pokitRootViewOnAppeared).finish() }
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
                action: { send(.filterButtonTapped(.포킷)) }
            )

            PokitIconLButton(
                "미분류",
                .icon(.info),
                state: store.folderType == .folder(.미분류)
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.filterButtonTapped(.미분류)) }
            )

            Spacer()

            PokitIconLTextLink(
                store.sortType == .sort(.최신순) ?
                "최신순" : store.folderType == .folder(.포킷) ? "이름순" : "오래된순",
                icon: .icon(.align),
                action: { send(.sortButtonTapped) }
            )
            .contentTransition(.numericText())
        }
        .animation(.snappy(duration: 0.7), value: store.folderType)
    }

    var cardScrollView: some View {
        Group {
            if store.folderType == .folder(.포킷) {
                pokitView
            } else {
                unclassifiedView
            }
        }
        .padding(.top, 20)
        .scrollIndicators(.hidden)
        .animation(.pokitDissolve, value: store.folderType)
    }

    var pokitView: some View {
        Group {
            if let categories = store.categories {
                if categories.isEmpty {
                    VStack {
                        PokitCaution(
                            image: .empty,
                            titleKey: "저장된 포킷이 없어요!",
                            message: "포킷을 생성해 링크를 저장해보세요"
                        )
                        .padding(.top, 36)

                        Spacer()
                    }
                } else {
                    pokitList(categories)
                }
            } else {
                PokitLoading()
            }
        }
    }

    @ViewBuilder
    func pokitList(_ categories: IdentifiedArrayOf<BaseCategoryItem>) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                LazyVGrid(columns: column, spacing: 12) {
                    ForEach(categories, id: \.id) { item in
                        PokitCard(
                            category: item,
                            action: { send(.categoryTapped(item)) },
                            kebabAction: { send(.kebobButtonTapped(item)) }
                        )
                    }
                }

                if store.hasNext {
                    PokitLoading()
                        .onAppear { send(.다음페이지_로딩_presented) }
                }
            }
            .padding(.bottom, 150)
        }
    }

    var unclassifiedView: some View {
        Group {
            if let unclassifiedContents = store.unclassifiedContents {
                if unclassifiedContents.isEmpty {
                    VStack {
                        PokitCaution(
                            image: .empty,
                            titleKey: "저장된 링크가 없어요!",
                            message: "다양한 링크를 한 곳에 저장해보세요"
                        )
                        .padding(.top, 36)

                        Spacer()
                    }
                } else {
                    unclassifiedList(unclassifiedContents)
                }
            } else {
                PokitLoading()
            }
        }
    }

    @ViewBuilder
    func unclassifiedList(_ unclassifiedContents: IdentifiedArrayOf<BaseContentItem>) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(unclassifiedContents) { content in
                    let isFirst = content == unclassifiedContents.first
                    let isLast = content == unclassifiedContents.last

                    PokitLinkCard(
                        link: content,
                        action: { send(.contentItemTapped(content)) },
                        kebabAction: { send(.unclassifiedKebobButtonTapped(content)) }
                    )
                    .divider(isFirst: isFirst, isLast: isLast)
                }

                if store.unclassifiedHasNext {
                    PokitLoading()
                        .onAppear(perform: { send(.다음페이지_로딩_presented) })
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


