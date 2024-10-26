//
//  MainTabSplitFeature.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import ComposableArchitecture
import FeatureSetting
import FeatureCategoryDetail
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureContentList
import FeatureCategorySharing
import Domain
import Util

@Reducer
public struct MainTabSplitFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public enum State {
        case pokit(PokitSplitFeature.State)
        case remind(RemindSplitFeature.State)
        public init() { self = .pokit(.init()) }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case pokit(PokitSplitFeature.Action)
        case remind(RemindSplitFeature.Action)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable {
            case 포킷_버튼_눌렀을때
            case 리마인드_버튼_눌렀을때
            case 추가_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction {
            case pokit(PokitSplitFeature.Action)
            case remind(RemindSplitFeature.Action)
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
        case .pokit(let pokitAction):
            return .send(.scope(.pokit(pokitAction)))
        case .remind(let remindAction):
            return .send(.scope(.remind(remindAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifCaseLet(\.pokit, action: \.pokit) { PokitSplitFeature() }
            .ifCaseLet(\.remind, action: \.remind) { RemindSplitFeature() }
    }
}
//MARK: - FeatureAction Effect
private extension MainTabSplitFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .포킷_버튼_눌렀을때:
            state = .pokit(.init())
            return .none
        case .리마인드_버튼_눌렀을때:
            state = .remind(.init())
            return .none
        case .추가_버튼_눌렀을때:
            switch state {
            case .pokit:
                return .send(.pokit(.delegate(.링크추가및수정_활성화)))
            case .remind:
                return .none
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
