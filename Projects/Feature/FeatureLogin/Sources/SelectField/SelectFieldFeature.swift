//
//  SelectFieldFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import CoreKit

@Reducer
public struct SelectFieldFeature {
    /// - Dependency

    /// - State
    public struct State: Equatable {
        public init() {}
    }
    /// - Action
    @ObservableState
    public enum Action: FeatureAction {
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        public enum ViewAction: Equatable { case doNothing }
        public enum InnerAction: Equatable { case doNothing }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
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
        return .none
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
