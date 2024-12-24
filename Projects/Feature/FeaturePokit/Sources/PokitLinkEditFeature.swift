//
//  PokitLinkEditFeature.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import ComposableArchitecture
import Domain
import Util

@Reducer
public struct PokitLinkEditFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var item: BaseContentListInquiry
        var list = IdentifiedArrayOf<BaseContentItem>()
        var selectedItems = IdentifiedArrayOf<BaseContentItem>()
        
        public init(linkList: BaseContentListInquiry) {
            self.item = linkList
            if let data = self.item.data {
                data.forEach { list.append($0) }
            }
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
        public enum View: Equatable { case 체크박스_선택했을때(BaseContentItem) }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
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
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension PokitLinkEditFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case let .체크박스_선택했을때(item):
            /// 이미 체크되어 있다면 해제
            if state.selectedItems.contains(item) {
                state.selectedItems.remove(id: item.id)
            } else {
                state.selectedItems.append(item)
            }
            return .none
        }
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
