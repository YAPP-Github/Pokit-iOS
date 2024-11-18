//
//  PokitSearchView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
import FeatureContentCard
import DSKit

@ViewAction(for: PokitSearchFeature.self)
public struct PokitSearchView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<PokitSearchFeature>
    @FocusState
        private var focused: Bool
    
    /// - Initializer
    public init(store: StoreOf<PokitSearchFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension PokitSearchView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                navigationBar
                
                recentSearch
                    .padding(.top, 20)
                
                PokitDivider()
                    .padding(.top, 28)
                
                resultList
                
                Spacer()
            }
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .sheet(
                item: $store.scope(
                    state: \.filterBottomSheet,
                    action: \.fiterBottomSheet
                )
            ) { store in
                FilterBottomSheet(store: store)
            }
            .sheet(item: $store.bottomSheetItem) { content in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheet(delegate: $0, content: content)) }
            }
            .sheet(item: $store.shareSheetItem) { content in
                if let shareURL = URL(string: content.data) {
                    PokitShareSheet(
                        items: [shareURL],
                        completion: { send(.링크_공유_완료되었을때) }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(item: $store.alertItem) { content in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.링크_삭제_눌렀을때) }
            }
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension PokitSearchView {
    var navigationBar: some View {
        HStack(spacing: 8) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
            
            PokitIconRInput(
                text: $store.searchText,
                icon: store.isSearching ? .icon(.x) : .icon(.search),
                shape: .round,
                focusState: $focused,
                equals: true,
                onSubmit: { send(.검색_키보드_엔터_눌렀을때) },
                iconTappedAction: store.isSearching ? { send(.검색_버튼_눌렀을때) } : nil
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
    }
    
    var recentSearchTitle: some View {
        HStack(spacing: 4) {
            Text("최근 검색어")
                .pokitFont(.b2(.b))
                .foregroundStyle(.pokit(.text(.primary)))
            
            Spacer()
            
            PokitTextLink(
                "전체 삭제",
                color: .text(.tertiary),
                action: { send(.전체_삭제_버튼_눌렀을때) }
            )
            
            Text("|")
                .pokitFont(.b3(.m))
                .foregroundStyle(.pokit(.text(.tertiary)))
            
            PokitTextLink(
                "자동저장 \(store.isAutoSaveSearch ? "끄기" : "켜기")",
                color: .text(.tertiary),
                action: { send(.자동저장_버튼_눌렀을때, animation: .pokitSpring) }
            )
            .contentTransition(.numericText())
        }
        .padding(.horizontal, 20)
    }
    
    var recentSearch: some View {
        VStack(spacing: 20) {
            recentSearchTitle
            
            if store.isSearching {
                filterToolbar
            } else if store.isAutoSaveSearch {
                if store.recentSearchTexts.isEmpty {
                    Text("검색 내역이 없습니다.")
                        .pokitFont(.b3(.r))
                        .foregroundStyle(.pokit(.text(.tertiary)))
                        .pokitBlurReplaceTransition(.pokitDissolve)
                        .padding(.vertical, 5)
                } else {
                    recentSearchList
                }
            } else {
                Text("최근 검색 저장 기능이 꺼져있습니다.")
                    .pokitFont(.b3(.r))
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .pokitBlurReplaceTransition(.pokitDissolve)
                    .padding(.vertical, 5)
            }
        }
    }
    
    var recentSearchList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(store.recentSearchTexts, id: \.self) { text in
                    PokitIconRChip(
                        text,
                        state: .default(.primary),
                        size: .small,
                        action: {
                            send(.최근검색_태그_눌렀을때(text: text), animation: .pokitSpring)
                        },
                        iconTappedAction: {
                            send(.최근검색_태그_삭제_눌렀을때(searchText: text), animation: .pokitSpring)
                        }
                    )
                    .pokitScrollTransition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 1)
        }
        .pokitBlurReplaceTransition(.pokitDissolve)
    }
    
    var filterToolbar: some View {
        HStack(spacing: 0) {
            filterButton
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Group {
                        categoryFilterButton
                        
                        contentTypeFilterButton
                        
                        dateFilterButton
                    }
                    .pokitScrollTransition(.opacity)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
            }
        }
        .padding(.leading, 20)
        .pokitBlurReplaceTransition(.pokitDissolve)
    }
    
    var filterButton: some View {
        PokitIconLButton(
            "필터",
            .icon(.filter),
            state: store.isFiltered ? .filled(.primary) : .stroke(.secondary),
            size: .small,
            shape: .round,
            action: { send(.필터링_버튼_눌렀을때) }
        )
    }
    
    var categoryFilterButton: some View {
        Group {
            if store.categoryFilter.isEmpty {
                PokitIconRChip(
                    "포킷",
                    icon: .icon(.arrowDown),
                    state: .default(.primary),
                    size: .small,
                    action: { send(.카테고리_버튼_눌렀을때) }
                )
            } else {
                ForEach(store.categoryFilter) { category in
                    PokitIconRChip(
                        category.categoryName,
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.카테고리_태그_눌렀을때(category: category), animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
            }
        }
    }
    
    var contentTypeFilterButton: some View {
        Group {
            if !store.favoriteFilter && !store.unreadFilter {
                PokitIconRChip(
                    "모아보기",
                    icon: .icon(.arrowDown),
                    state: .default(.primary),
                    size: .small,
                    action: { send(.모아보기_버튼_눌렀을때) }
                )
            } else {
                if store.favoriteFilter {
                    PokitIconRChip(
                        "즐겨찾기",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.즐겨찾기_태그_눌렀을때, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.unreadFilter {
                    PokitIconRChip(
                        "안읽음",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.안읽음_태그_눌렀을때, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
            }
        }
    }
    
    var dateFilterButton: some View {
        PokitIconRChip(
            store.dateFilterText,
            icon: store.dateFilterText == "기간" ? .icon(.arrowDown) : .icon(.x),
            state: store.dateFilterText == "기간" ? .default(.primary) : .stroke(.primary),
            size: .small,
            action: { send(.기간_버튼_눌렀을때, animation: .pokitSpring) }
        )
        .pokitBlurReplaceTransition(.pokitDissolve)
    }
    
    var resultList: some View {
        VStack(alignment: .leading, spacing: 20) {
            PokitIconLTextLink(
                store.isResultAscending ? "오래된순" : "최신순",
                icon: .icon(.align),
                action: { send(.정렬_버튼_눌렀을때) }
            )
            .contentTransition(.numericText())
            .padding(.horizontal, 20)
            
            if !store.isLoading {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEachStore(
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
                                .task { await send(.로딩중일때, animation: .pokitDissolve).finish() }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            } else {
                PokitLoading()
            }
        }
        .padding(.top, 24)
    }
}
//MARK: - Preview
#Preview {
    PokitSearchView(
        store: Store(
            initialState: .init(),
            reducer: { PokitSearchFeature() }
        )
    )
}


