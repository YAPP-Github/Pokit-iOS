//
//  FilterBottomFeature.swift
//  Feature
//
//  Created by 김도형 on 7/27/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct FilterBottomFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(
            filterType currentType: FilterType,
            pokitFilter selectedPokit: IdentifiedArrayOf<BaseCategoryItem>,
            favoriteFilter isFavorite: Bool,
            unreadFilter isUnread: Bool,
            startDateFilter startDate: Date?,
            endDateFilter endDate: Date?
        ) {
            self.currentType = currentType
            self.selectedCategories = selectedPokit
            self.isFavorite = isFavorite
            self.isUnread = isUnread
            self.dateSelected = startDate != nil || endDate != nil
            self.startDate = startDate ?? .now
            self.endDate = endDate ?? .now
        }
        
        var currentType: FilterType
        
        var selectedCategories = IdentifiedArrayOf<BaseCategoryItem>()
        var isFavorite: Bool
        var isUnread: Bool
        var dateSelected: Bool
        var startDate: Date
        var endDate: Date
        var startDateText: String {
            let fomatter = DateFormatter()
            fomatter.dateFormat = "yy.MM.dd"
            return fomatter.string(from: startDate)
        }
        var endDateText: String {
            let fomatter = DateFormatter()
            fomatter.dateFormat = "yy.MM.dd"
            return fomatter.string(from: endDate)
        }
        
        fileprivate var domain = FilterBottom()
        var pokitList: [BaseCategoryItem] {
            get { domain.categoryList.data }
        }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case pokitListCellTapped(pokit: BaseCategoryItem)
            case searchButtonTapped
            case pokitChipTapped(BaseCategoryItem)
            case favoriteChipTapped
            case unreadChipTapped
            case dateChipTapped
            case favoriteButtonTapped
            case unreadButtonTapped
            
            case filterBottomSheetOnAppeard
        }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case searchButtonTapped(
                categories: IdentifiedArrayOf<BaseCategoryItem>,
                isFavorite: Bool,
                isUnread: Bool,
                startDate: Date?,
                endDate: Date?
            )
        }
    }
    
    /// - Initiallizer
    public init() {}

    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            /// - View
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
            
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            
            /// - Delegate
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension FilterBottomFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.startDate):
                state.dateSelected = true
            return .none
        case .binding(\.endDate):
                state.dateSelected = true
            return .none
        case .binding:
            return .none
        case .pokitListCellTapped(let pokit):
            state.selectedCategories.append(pokit)
            return .none
        case .searchButtonTapped:
            return .run { [
                categories = state.selectedCategories,
                isFavorite = state.isFavorite,
                isUnread = state.isUnread,
                startDate = state.startDate,
                endDate = state.endDate,
                dateSelected = state.dateSelected
            ] send in
                await send(.delegate(.searchButtonTapped(
                    categories: categories,
                    isFavorite: isFavorite,
                    isUnread: isUnread,
                    startDate: dateSelected ? startDate : nil,
                    endDate: dateSelected ? endDate : nil
                )))
                await dismiss()
            }
        case .pokitChipTapped(let category):
            state.selectedCategories.remove(category)
            return .none
        case .favoriteChipTapped:
            state.isFavorite = false
            return .none
        case .unreadChipTapped:
            state.isUnread = false
            return .none
        case .dateChipTapped:
            state.startDate = .now
            state.endDate = .now
            state.dateSelected = false
            return .none
        case .favoriteButtonTapped:
            state.isFavorite.toggle()
            return .none
        case .unreadButtonTapped:
            state.isUnread.toggle()
            return .none
        case .filterBottomSheetOnAppeard:
            // - MARK: 더미 조회
            state.domain.categoryList = CategoryListInquiryResponse.mock.toDomain()
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}

public extension FilterBottomFeature {
    enum FilterType {
        case pokit
        case contentType
        case date
    }
}
