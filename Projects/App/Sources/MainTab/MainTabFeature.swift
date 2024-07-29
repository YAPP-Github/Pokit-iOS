//
//  MainTabFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import FeaturePokit
import FeatureRemind
import Util

@Reducer
public struct MainTabFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var selectedTab: MainTab = .pokit
        var isBottomSheetPresented: Bool = false
        var pokit: PokitRootFeature.State
        var remind: RemindFeature.State = .init()
        
        public init() {
            self.pokit = .init(mock: PokitRootCardMock.mock, unclassifiedMock: LinkMock.recommendedMock)
        }
    }
    /// - Action
    public enum Action: FeatureAction, BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        /// Todo: scope로 이동
        case pokit(PokitRootFeature.Action)
        case remind(RemindFeature.Action)

        @CasePathable
        public enum View: Equatable {
            case addButtonTapped
        }
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
        case .binding:
            return .none
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
            
        case .pokit:
            return .none
        case .remind:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Scope(state: \.pokit, action: \.pokit) { PokitRootFeature() }
        Scope(state: \.remind, action: \.remind) { RemindFeature() }
        
        BindingReducer()
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension MainTabFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .addButtonTapped:
            state.isBottomSheetPresented.toggle()
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
