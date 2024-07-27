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
    @State
    private var currentTab: Tab = .pokit
    
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
                
                switch currentTab {
                case .pokit:
                    PokitList(
                        selectedItem: store.selectedPokit,
                        list: store.pokitList.elements,
                        action: { send(.pokitListCellTapped(pokit: $0), animation: .pokitSpring) }
                    )
                case .linkType:
                    linkTypes
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
                        action: {}
                    )
                    .background()
                }
            }
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
                selection: $currentTab,
                to: .pokit
            )
            .matchedGeometryEffectBackground(id: heroEffect)
            
            PokitPartTap(
                "모아보기",
                selection: $currentTab,
                to: .linkType
            )
            .matchedGeometryEffectBackground(id: heroEffect)
            
            PokitPartTap(
                "기간",
                selection: $currentTab,
                to: .date
            )
            .matchedGeometryEffectBackground(id: heroEffect)
        }
    }
    
    var linkTypes: some View {
        VStack(spacing: 0) {
            linkTypeButton(
                "즐겨찾기",
                isSelected: $store.isFavorite,
                action: {}
            )
            
            linkTypeButton(
                "안읽음",
                isSelected: $store.isUnread,
                action: {}
            )
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func linkTypeButton(
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
                if let pokit = store.selectedPokit?.categoryType {
                    PokitIconRChip(
                        pokit,
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.pokitChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.smooth)
                }
                
                if store.isFavorite {
                    PokitIconRChip(
                        "즐겨찾기",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.favoriteChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.smooth)
                }
                
                if store.isUnread {
                    PokitIconRChip(
                        "안읽음",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.unreadChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.smooth)
                }
                
                if store.dateSelected {
                    let sameDate = store.startDate == store.endDate
                    PokitIconRChip(
                        sameDate ? "\(store.startDateText)" : "\(store.startDateText) ~ \(store.endDateText)",
                        state: .stroke(.primary),
                        size: .small,
                        action: { send(.dateChipTapped, animation: .pokitSpring) }
                    )
                    .pokitBlurReplaceTransition(.smooth)
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

private extension FilterBottomSheet {
    enum Tab {
        case pokit
        case linkType
        case date
    }
}

//MARK: - Preview
#Preview {
    FilterBottomSheet(
        store: Store(
            initialState: .init(),
            reducer: { FilterBottomFeature() }
        )
    )
}


