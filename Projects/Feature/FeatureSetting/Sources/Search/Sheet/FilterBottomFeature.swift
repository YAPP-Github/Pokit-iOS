//
//  FilterBottomFeature.swift
//  Feature
//
//  Created by 김도형 on 7/27/24.

import Foundation

import ComposableArchitecture
import Util

@Reducer
public struct FilterBottomFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {
            SearchPokitMock.addLinkMock.forEach { self.pokitList.append($0) }
        }
        
        var pokitList: IdentifiedArrayOf<SearchPokitMock> = .init()
        var selectedPokit: SearchPokitMock? = nil
        var isFavorite: Bool = false
        var isUnread: Bool = false
        var dateSelected: Bool = false
        var startDate: Date = .now
        var endDate: Date = .now
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
            case pokitListCellTapped(pokit: SearchPokitMock)
            case searchButtonTapped
            case pokitChipTapped
            case favoriteChipTapped
            case unreadChipTapped
            case dateChipTapped
        }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case searchButtonTapped(
                pokit: SearchPokitMock?,
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
            state.selectedPokit = pokit
            return .none
        case .searchButtonTapped:
            return .run { [
                pokit = state.selectedPokit,
                isFavorite = state.isFavorite,
                isUnread = state.isUnread,
                startDate = state.startDate,
                endDate = state.endDate,
                dateSelected = state.dateSelected
            ] send in
                await send(.delegate(.searchButtonTapped(
                    pokit: pokit,
                    isFavorite: isFavorite,
                    isUnread: isUnread,
                    startDate: dateSelected ? startDate : nil,
                    endDate: dateSelected ? endDate : nil
                )))
                await dismiss()
            }
        case .pokitChipTapped:
            state.selectedPokit = nil
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
