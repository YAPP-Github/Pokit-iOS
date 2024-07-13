//
//  RemindFeature.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import ComposableArchitecture
import CoreKit
import DSKit

@Reducer
public struct RemindFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var recommendedLinks = LinkMock.recommendedMock
        var unreadLinks = LinkMock.unreadMock
        var favoriteLinks = LinkMock.favoriteMock
        var showBottomSheet = false
    }
    /// - Action
    public enum Action: FeatureAction, BindableAction {
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        
        public enum ViewAction: Equatable {
            case bellButtonTapped
            case searchButtonTapped
            case linkCardTapped(LinkMock)
            case kebabButtonTapped
            case unreadNavigationLinkTapped
            case favoriteNavigationLinkTapped
        }
        public enum InnerAction: Equatable { case doNothing }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable {
            case bottomSheet(PokitBottomSheet.Delegate, LinkMock)
        }
        public enum DelegateAction: Equatable { case doNothing }
    }
    /// initiallizer
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
        case .binding(let bindingAction):
            return handleBindingAction(bindingAction, state: &state)
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension RemindFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .bellButtonTapped:
            return .none
        case .searchButtonTapped:
            return .none
        case .favoriteNavigationLinkTapped:
            return .none
        case .unreadNavigationLinkTapped:
            return .none
        case .kebabButtonTapped:
            state.showBottomSheet = true
            return .none
        case .linkCardTapped(let link):
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
        switch action {
        case .bottomSheet(let delegate, let link):
            switch delegate {
            case .deleteCellButtonTapped:
                return .none
            case .editCellButtonTapped:
                return .none
            case .favoriteCellButtonTapped:
                return .none
            case .shareCellButtonTapped:
                print(link)
                return .none
            }
        }
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    func handleBindingAction(_ action: BindingAction<State>, state: inout State) -> Effect<Action> {
        switch action {
        case \.showBottomSheet:
            return .none
        default:
            return .none
        }
    }
}
