//
//  DemoFeature.swift
//  Feature
//
//  Created by 김도형 on 12/24/24.

import ComposableArchitecture
import Util

@Reducer
public struct DemoFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public enum State {
        case intro(IntroFeature.State = .init())
        case main
        
        public init() { self = .intro() }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case intro(IntroFeature.Action)
        
        @CasePathable
        public enum View: Equatable { case doNothing }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction {
            case intro(IntroFeature.Action)
        }
        
        public enum DelegateAction: Equatable { case doNothing }
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
            
        case .intro(let introAction):
            return shared(.scope(.intro(introAction)), state: &state)
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
    }
}
//MARK: - FeatureAction Effect
private extension DemoFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
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
        switch action {
        case .intro(.delegate(.moveToTab)):
            state = .main
            return .none
        case .intro: return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    func shared(_ action: Action, state: inout State) -> Effect<Action> {
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
            
        case .intro(let introAction):
            return shared(.scope(.intro(introAction)), state: &state)
        }
    }
}
