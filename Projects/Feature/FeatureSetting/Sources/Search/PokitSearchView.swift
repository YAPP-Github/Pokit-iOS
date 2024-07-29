//
//  PokitSearchView.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import SwiftUI

import ComposableArchitecture
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
                
                if !store.resultMock.isEmpty {
                    resultList
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .sheet(
                item: $store.scope(
                    state: \.filterBottomSheet,
                    action: \.fiterBottomSheet
                )
            ) { store in
                FilterBottomSheet(store: store)
            }
            .sheet(item: $store.bottomSheetItem) { link in
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224
                ) { send(.bottomSheetButtonTapped(delegate: $0, link: link)) }
            }
            .sheet(item: $store.alertItem) { link in
                PokitAlert(
                    "링크를 정말 삭제하시겠습니까?",
                    message: "함께 저장한 모든 정보가 삭제되며, \n복구하실 수 없습니다.",
                    confirmText: "삭제"
                ) { send(.deleteAlertConfirmTapped(link: link)) }
            }
        }
    }
}
//MARK: - Configure View
private extension PokitSearchView {
    var navigationBar: some View {
        HStack(spacing: 8) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.backButtonTapped) }
            )
            
            PokitIconRInput(
                text: $store.searchText,
                icon: store.isSearching ? .icon(.x) : .icon(.search),
                shape: .round,
                focusState: $focused,
                equals: true,
                onSubmit: { send(.searchTextInputOnSubmitted) },
                iconTappedAction: store.isSearching ? { send(.searchTextInputIconTapped) } : nil
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
                action: { send(.recentSearchAllRemoveButtonTapped) }
            )
            
            Text("|")
                .pokitFont(.b3(.m))
                .foregroundStyle(.pokit(.text(.tertiary)))
            
            PokitTextLink(
                "자동저장 \(store.isAutoSaveSearch ? "끄기" : "켜기")",
                color: .text(.tertiary),
                action: { send(.autoSaveButtonTapped, animation: .pokitSpring) }
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
                        .pokitBlurReplaceTransition(.smooth)
                        .padding(.vertical, 5)
                } else {
                    recentSearchList
                }
            } else {
                Text("최근 검색 저장 기능이 꺼져있습니다.")
                    .pokitFont(.b3(.r))
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .pokitBlurReplaceTransition(.smooth)
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
                            send(.searchTextChipButtonTapped(text: text), animation: .pokitSpring)
                        },
                        iconTappedAction: {
                            send(.recentSearchChipIconTapped(searchText: text), animation: .pokitSpring)
                        }
                    )
                    .pokitScrollTransition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 1)
        }
        .pokitBlurReplaceTransition(.smooth)
    }
    
    var filterToolbar: some View {
        HStack(spacing: 0) {
            filterButton
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Group {
                        pokitFilterButton
                        
                        linkTypeFilterButton
                        
                        dateFilterButton
                    }
                    .pokitScrollTransition(.opacity)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
            }
        }
        .padding(.leading, 20)
        .pokitBlurReplaceTransition(.smooth)
    }
    
    var filterButton: some View {
        PokitIconLButton(
            "필터",
            .icon(.filter),
            state: store.isFiltered ? .filled(.primary) : .stroke(.secondary),
            size: .small,
            shape: .round,
            action: { send(.filterButtonTapped) }
        )
    }
    
    var pokitFilterButton: some View {
        PokitIconRButton(
            store.pokitFilter?.categoryType ?? "포킷명",
            .icon(.arrowDown),
            state: store.pokitFilter == nil ? .default(.primary) : .stroke(.primary),
            size: .small,
            shape: .round,
            action: { send(.pokitFilterButtonTapped) }
        )
    }
    
    var linkTypeFilterButton: some View {
        PokitIconRButton(
            store.linkTypeText,
            .icon(.arrowDown),
            state: store.favoriteFilter || store.unreadFilter ? .stroke(.primary) : .default(.primary),
            size: .small,
            shape: .round,
            action: { send(.linkTypeFilterButtonTapped) }
        )
    }
    
    var dateFilterButton: some View {
        PokitIconRButton(
            store.dateFilterText,
            .icon(.arrowDown),
            state: store.dateFilterText == "기간" ? .default(.primary) : .stroke(.primary),
            size: .small,
            shape: .round,
            action: { send(.dateFilterButtonTapped) }
        )
    }
    
    var resultList: some View {
        VStack(alignment: .leading, spacing: 20) {
            PokitIconLTextLink(
                store.isResultAscending ? "최신순" : "오래된순",
                icon: .icon(.align),
                action: { send(.sortTextLinkTapped, animation: .smooth) }
            )
            .contentTransition(.numericText())
            .padding(.horizontal, 20)
            
            ScrollView {
                LazyVStack {
                    ForEach(store.resultMock) { link in
                        let isFirst = link == store.resultMock.first
                        let isLast = link == store.resultMock.last
                        
                        PokitLinkCard(
                            link: link,
                            action: { send(.linkCardTapped(link: link)) },
                            kebabAction: { send(.kebabButtonTapped(link: link)) }
                        )
                        .divider(isFirst: isFirst, isLast: isLast)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 24)
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


