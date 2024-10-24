//
//  RemindSplitFeature.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import ComposableArchitecture
import FeaturePokit
import FeatureCategoryDetail
import FeatureCategorySetting
import FeatureCategorySharing
import FeatureSetting
import FeatureContentSetting
import FeatureContentDetail
import FeatureRemind
import FeatureContentDetail
import Domain
import Util

@Reducer
public struct RemindSplitFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var pokit: PokitRootFeature.State = .init()
        var categoryDetail: CategoryDetailFeature.State?
        var contentSetting: ContentSettingFeature.State?
        
        @Presents
        var categorySetting: PokitCategorySettingFeature.State?
        @Presents
        var search: PokitSearchFeature.State?
        @Presents
        var setting: PokitSettingFeature.State?
        @Presents
        var contentDetail: ContentDetailFeature.State?
        
        @Shared(.inMemory("PushTapped"))
        var isPushTapped: Bool = false
        
        public init() {}
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case pokit(PokitRootFeature.Action)
        case categoryDetail(CategoryDetailFeature.Action)
        case contentSetting(ContentSettingFeature.Action)
        
        @CasePathable
        public enum View: Equatable {
            case 뷰가_나타났을때
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_상세_활성화(BaseCategoryItem)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction {
            case pokit(PokitRootFeature.Action)
            case categoryDetail(CategoryDetailFeature.Action)
            case contentSetting(ContentSettingFeature.Action)
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
        case .categoryDetail(let categoryDetailAction):
            return .send(.scope(.categoryDetail(categoryDetailAction)))
        case .contentSetting(let contentSettingAction):
            return .send(.scope(.contentSetting(contentSettingAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension RemindSplitFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_상세_활성화(category):
            state.categoryDetail = .init(category: category)
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .pokit(.delegate(.categoryTapped(category))):
            return .send(.inner(.카테고리_상세_활성화(category)))
        case .pokit:
            return .none
        case .categoryDetail:
            return .none
        case .contentSetting:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
