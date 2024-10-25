//
//  PokitSplitFeature.swift
//  App
//
//  Created by 김도형 on 10/24/24.

import SwiftUI

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
public struct PokitSplitFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
        
        var 포킷: PokitRootFeature.State = .init()
        var 카테고리상세: CategoryDetailFeature.State?
        var 링크추가및수정: ContentSettingFeature.State = .init()
        
        @Presents
        var 포킷추가및수정: PokitCategorySettingFeature.State?
        @Presents
        var 검색: PokitSearchFeature.State?
        @Presents
        var 설정: PokitSettingFeature.State?
        @Presents
        var 링크상세: ContentDetailFeature.State?
        
        @Shared(.inMemory("SelectCategory"))
        var categoryId: Int?
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
        case 포킷(PokitRootFeature.Action)
        case 카테고리상세(CategoryDetailFeature.Action)
        case 링크추가및수정(ContentSettingFeature.Action)
        case 포킷추가및수정(PokitCategorySettingFeature.Action)
        case 검색(PokitSearchFeature.Action)
        case 설정(PokitSettingFeature.Action)
        case 링크상세(ContentDetailFeature.Action)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            
            case 뷰가_나타났을때
            case 검색_버튼_눌렀을때
            case 알람_버튼_눌렀을때
            case 설정_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_상세_활성화(BaseCategoryItem)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction {
            case 포킷(PokitRootFeature.Action)
            case 카테고리상세(CategoryDetailFeature.Action)
            case 링크추가및수정(ContentSettingFeature.Action)
            case 포킷추가및수정(PokitCategorySettingFeature.Action)
            case 검색(PokitSearchFeature.Action)
            case 설정(PokitSettingFeature.Action)
            case 링크상세(ContentDetailFeature.Action)
        }
        
        public enum DelegateAction: Equatable { case 없음 }
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
        case .포킷(let pokitAction):
            return .send(.scope(.포킷(pokitAction)))
        case .카테고리상세(let categoryDetailAction):
            return .send(.scope(.카테고리상세(categoryDetailAction)))
        case .링크추가및수정(let contentSettingAction):
            return .send(.scope(.링크추가및수정(contentSettingAction)))
        case .포킷추가및수정(let categorySettingAction):
            return .send(.scope(.포킷추가및수정(categorySettingAction)))
        case .검색(let searchAction):
            return .send(.scope(.검색(searchAction)))
        case .설정(let settingAction):
            return .send(.scope(.설정(settingAction)))
        case .링크상세(let contentDetailAction):
            return .send(.scope(.링크상세(contentDetailAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Scope(state: \.포킷, action: \.포킷) {
            PokitRootFeature()
        }
        Scope(state: \.링크추가및수정, action: \.링크추가및수정) {
            ContentSettingFeature()
        }
        
        Reduce(self.core)
            .ifLet(\.카테고리상세, action: \.카테고리상세) {
                CategoryDetailFeature()
            }
            .ifLet(\.포킷추가및수정, action: \.포킷추가및수정) {
                PokitCategorySettingFeature()
            }
            .ifLet(\.검색, action: \.검색) {
                PokitSearchFeature()
            }
            .ifLet(\.설정, action: \.설정) {
                PokitSettingFeature()
            }
            .ifLet(\.링크상세, action: \.링크상세) {
                ContentDetailFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension PokitSplitFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_상세_활성화(category):
            state.카테고리상세 = .init(category: category)
            return .send(.카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회)))
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .포킷(.delegate(.categoryTapped(category))):
            state.categoryId = category.id
            return .send(.inner(.카테고리_상세_활성화(category)))
        case .포킷(.delegate(.카테고리_삭제)):
            state.카테고리상세 = nil
            return .none
        case .포킷:
            return .none
            
        case .카테고리상세:
            return .none
            
        case .링크추가및수정:
            return .none
            
        case .포킷추가및수정:
            return .none
            
        case .검색:
            return .none
            
        case .설정:
            return .none
            
        case .링크상세:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}

extension PokitSplitFeature {
    @Reducer
    enum Path {
        case 알림함(PokitAlertBoxFeature)
    }
}
