//
//  SplashFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import Util

@Reducer
public struct SplashFeature {
    /// - Dependency
    @Dependency(\.continuousClock) var clock
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
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
            case onAppear
        }
        public enum InnerAction: Equatable { case doNothing }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case loginNeeded
            case autoLoginSuccess
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
private extension SplashFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                /// Todo: userdefault를 통해 로그인할 수 있다면 로그인하기
                /// - if (로그인체크) {} else {}
                try await self.clock.sleep(for: .milliseconds(2000))
                await send(.delegate(.loginNeeded))
            }
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
