//
//  SelectFieldFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import Util

@Reducer
public struct SelectFieldFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var fields: [String] = [
            "스포츠/레저",
            "문구/오피스",
            "패션",
            "여행",
            "경제/시사",
            "영화/드라마",
            "맛집",
            "인테리어",
            "IT",
            "디자인",
            "자기계발",
            "유머",
            "음악",
            "취업정보"
        ]
        
        var selectedFields: Set<String> = .init()
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable {
            case nextButtonTapped
            case backButtonTapped
            case fieldChipTapped(String)
        }
        public enum InnerAction: Equatable { case doNothing }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case pushSignUpDoneView
        }
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
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension SelectFieldFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .nextButtonTapped:
            return .send(.delegate(.pushSignUpDoneView))
        case .backButtonTapped:
            return .run { _ in await self.dismiss() }
        case .fieldChipTapped(let field):
            let result = state.selectedFields.remove(field)
            guard result == nil else { return .none }
            state.selectedFields.insert(field)
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
