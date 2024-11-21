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
            VStack(spacing: 0) {
                tabs
                    .padding(.horizontal, 20)
                    .padding(.top, 36)
                    .padding(.bottom, 16)
                
                switch store.currentType {
                case .pokit:
                    pokitList
                        .onAppear { send(.뷰가_나타났을때) }
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
                        action: { send(.검색하기_버튼_눌렀을때, animation: .pokitSpring) }
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
                    action: { send(.포킷_항목_눌렀을때(pokit: $0), animation: .pokitSpring) }
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
                action: { send(.즐겨찾기_체크박스_눌렀을때, animation: .pokitSpring) }
            )
            
            contentTypeButton(
                "안읽음",
                isSelected: $store.isUnread,
                action: { send(.안읽음_체크박스_눌렀을때, animation: .pokitSpring) }
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
                    shape: .rectangle
                )
                
                Text(title)
                    .pokitFont(.b1(.m))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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
                        action: { send(.포킷_태그_눌렀을때(category), animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.isFavorite {
                    PokitIconRChip(
                        "즐겨찾기",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.즐겨찾기_태그_눌렀을때, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.isUnread {
                    PokitIconRChip(
                        "안읽음",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.안읽음_태그_눌렀을때, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.pokitDissolve)
                }
                
                if store.dateSelected {
                    let sameDate = store.startDate == store.endDate
                    PokitIconRChip(
                        sameDate ? "\(store.startDateText)" : "\(store.startDateText)~\(store.endDateText)",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.기간_태그_눌렀을때, animation: .pokitSpring) }
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
            reducer: { FilterBottomFeature()._printChanges() }
        )
    )
}


