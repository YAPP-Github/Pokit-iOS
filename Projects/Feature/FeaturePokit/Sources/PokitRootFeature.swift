//
//  PokitRootFeature.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import ComposableArchitecture
import Util

@Reducer
public struct PokitRootFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)
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
            /// - Navigaiton Bar
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped
            /// - Filter
            case filterButtonTapped(PokitRootFilterType.Folder)
            case sortButtonTapped
            

        }
        
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
private extension PokitRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        /// - Navigation Bar Tapped Action
        case .searchButtonTapped:
            return .none
        case .alertButtonTapped:
            return .none
        case .settingButtonTapped:
            return .none
        /// - Filter Action
        /// 포킷 / 미분류 버튼 눌렀을 때
        case .filterButtonTapped(let selectedFolderType):
            state.folderType = .folder(selectedFolderType)
            return .none
        /// 최신순 / 이름순 버튼 눌렀을 때
        case .sortButtonTapped:
            state.sortType = .sort(state.sortType == .sort(.이름순) ? .최신순 : .이름순)
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
