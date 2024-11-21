//
//  SignUpDoneFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import Foundation

import ComposableArchitecture
import DSKit
import Util

@Reducer
public struct SignUpDoneFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var firecrackIsAppear = false
        var titleIsAppear = false
        var confettiIsAppear = false
        var pookiIsAppear = false
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
            /// - Button Tapped
            case 시작_버튼_눌렀을때
            
            case 폭죽불꽃_이미지_나타났을때
            case 제목_나타났을때
            case 폭죽_이미지_나타났을때
            case 푸키_이미지_나타났을때
        }
        public enum InnerAction: Equatable { case 없음 }
        public enum AsyncAction: Equatable { case 없음 }
        public enum ScopeAction: Equatable { case 없음 }
        public enum DelegateAction: Equatable {
            case dismissLoginRootView
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
private extension SignUpDoneFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .시작_버튼_눌렀을때:
            return .send(.delegate(.dismissLoginRootView), animation: .pokitDissolve)
        case .폭죽불꽃_이미지_나타났을때:
            state.firecrackIsAppear = true
            return .none
        case .제목_나타났을때:
            state.titleIsAppear = true
            return .none
        case .폭죽_이미지_나타났을때:
            state.confettiIsAppear = true
            return .none
        case .푸키_이미지_나타났을때:
            state.pookiIsAppear = true
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
