//
//  FilterBottomView.swift
//  Feature
//
//  Created by 김도형 on 7/27/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: FilterBottomFeature.self)
public struct FilterBottomSheet: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<FilterBottomFeature>
    @Namespace
    private var heroEffect
    
    /// - Initializer
    public init(store: StoreOf<FilterBottomFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension FilterBottomSheet {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 4) {
                tabs
                    .padding(.horizontal, 20)
                    .padding(.top, 36)
                
                switch store.currentType {
                case .pokit:
                    pokitList
                        .onAppear { send(.pokitListOnAppeared) }
                case .contentType:
                    contentTypes
                case .date:
                    PokitCalendar(
                        startDate: $store.startDate,
                        endDate: $store.endDate
                    )
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                }
                
                VStack(spacing: 0) {
                    currentFilterChips
                    
                    PokitBottomButton(
                        "검색하기",
                        state: .filled(.primary),
                        action: { send(.searchButtonTapped, animation: .pokitSpring) }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(664)])
        }
    }
}
//MARK: - Configure View
private extension FilterBottomSheet {
    var tabs: some View {
        HStack(spacing: 4) {
            PokitPartTap(
                "포킷",
                selection: $store.currentType,
                to: .pokit
            )
            .backgound()
            
            PokitPartTap(
                "모아보기",
                selection: $store.currentType,
                to: .contentType
            )
            .backgound()
            
            PokitPartTap(
                "기간",
                selection: $store.currentType,
                to: .date
            )
            .backgound()
        }
    }
    
    var pokitList: some View {
        Group {
            if let pokitList = store.pokitList {
                PokitList(
                    selectedItem: nil,
                    list: pokitList,
                    action: { send(.pokitListCellTapped(pokit: $0), animation: .pokitSpring) }
                )
            } else {
                PokitLoading()
            }
        }
    }
    
    var contentTypes: some View {
        VStack(spacing: 0) {
            contentTypeButton(
                "즐겨찾기",
                isSelected: $store.isFavorite,
                action: { send(.favoriteButtonTapped, animation: .pokitSpring) }
            )
            
            contentTypeButton(
                "안읽음",
                isSelected: $store.isUnread,
                action: { send(.unreadButtonTapped, animation: .pokitSpring) }
            )
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func contentTypeButton(
        _ title: String,
        isSelected: Binding<Bool>,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                PokitCheckBox(
                    baseState: .default,
                    selectedState: .filled,
                    isSelected: isSelected,
                    shape: .round
                )
                
                Text(title)
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    var currentFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(store.selectedCategories) { category in
                    PokitIconRChip(
                        category.categoryName,
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.pokitChipTapped(category), animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.isFavorite {
                    PokitIconRChip(
                        "즐겨찾기",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.favoriteChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.isUnread {
                    PokitIconRChip(
                        "안읽음",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.unreadChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.dateSelected {
                    let sameDate = store.startDate == store.endDate
                    PokitIconRChip(
                        sameDate ? "\(store.startDateText)" : "\(store.startDateText)~\(store.endDateText)",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.dateChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                    .contentTransition(.numericText())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(minHeight: 64)
        .background(.pokit(.bg(.base)))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.pokit(.border(.tertiary)))
                .frame(height: 1)
        }
    }
}

//MARK: - Preview
#Preview {
    FilterBottomSheet(
        store: Store(
            initialState: .init(
                filterType: .pokit,
                pokitFilter: .init(),
                favoriteFilter: false,
                unreadFilter: false,
                startDateFilter: nil,
                endDateFilter: nil
            ),
            reducer: { FilterBottomFeature() }
        )
    )
}


