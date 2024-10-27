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
    public struct State {
        var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
        
        var 포킷: PokitRootFeature.State = .init()
        var 카테고리상세: CategoryDetailFeature.State?
        var 링크추가: ContentSettingFeature.State = .init()
        
        var path = StackState<Path.State>()
        
        @Presents
        var 포킷추가및수정: PokitCategorySettingFeature.State?
        @Presents
        var 설정: PokitSettingFeature.State?
        @Presents
        var 링크상세: ContentDetailFeature.State?
        @Presents
        var 알림함: PokitAlertBoxFeature.State?
        @Presents
        var 링크수정: ContentSettingFeature.State?
        
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
        case path(StackActionOf<Path>)
        case delegate(DelegateAction)
        case 포킷(PokitRootFeature.Action)
        case 카테고리상세(CategoryDetailFeature.Action)
        case 링크추가(ContentSettingFeature.Action)
        case 포킷추가및수정(PresentationAction<PokitCategorySettingFeature.Action>)
        case 설정(PresentationAction<PokitSettingFeature.Action>)
        case 링크상세(PresentationAction<ContentDetailFeature.Action>)
        case 알림함(PresentationAction<PokitAlertBoxFeature.Action>)
        case 링크수정(PresentationAction<ContentSettingFeature.Action>)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            
            case 뷰가_나타났을때
            case 포킷추가_버튼_눌렀을때
            case 검색_버튼_눌렀을때
            case 알람_버튼_눌렀을때
            case 설정_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_상세_활성화(BaseCategoryItem)
            case 포킷추가및수정_활성화(BaseCategoryItem?)
            case 링크수정_활성화(Int?)
            case 링크상세_활성화(Int)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction {
            case 포킷(PokitRootFeature.Action)
            case 카테고리상세(CategoryDetailFeature.Action)
            case 링크추가(ContentSettingFeature.Action)
            case 포킷추가및수정(PresentationAction<PokitCategorySettingFeature.Action>)
            case 검색(StackElementID, PokitSearchFeature.Action)
            case 설정(PresentationAction<PokitSettingFeature.Action>)
            case 링크상세(PresentationAction<ContentDetailFeature.Action>)
            case 알림함(PresentationAction<PokitAlertBoxFeature.Action>)
            case 링크수정(PresentationAction<ContentSettingFeature.Action>)
        }
        
        public enum DelegateAction: Equatable {
            case 링크추가_활성화
        }
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
        case .path(let pathAction):
            return handlePathAction(pathAction, state: &state)
        case .포킷(let pokitAction):
            return .send(.scope(.포킷(pokitAction)))
        case .카테고리상세(let categoryDetailAction):
            return .send(.scope(.카테고리상세(categoryDetailAction)))
        case .링크추가(let contentSettingAction):
            return .send(.scope(.링크추가(contentSettingAction)))
        case .포킷추가및수정(let categorySettingAction):
            return .send(.scope(.포킷추가및수정(categorySettingAction)))
        case .설정(let settingAction):
            return .send(.scope(.설정(settingAction)))
        case .링크상세(let contentDetailAction):
            return .send(.scope(.링크상세(contentDetailAction)))
        case .알림함(let alertAction):
            return .send(.scope(.알림함(alertAction)))
        case .링크수정(let contentSettingAction):
            return .send(.scope(.링크수정(contentSettingAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Scope(state: \.포킷, action: \.포킷) {
            PokitRootFeature()
        }
        Scope(state: \.링크추가, action: \.링크추가) {
            ContentSettingFeature()
        }
        
        Reduce(self.core)
            .forEach(\.path, action: \.path)
            .ifLet(\.카테고리상세, action: \.카테고리상세) {
                CategoryDetailFeature()
            }
            .ifLet(\.$포킷추가및수정, action: \.포킷추가및수정) {
                PokitCategorySettingFeature()
            }
            .ifLet(\.$설정, action: \.설정) {
                PokitSettingFeature()
            }
            .ifLet(\.$링크상세, action: \.링크상세) {
                ContentDetailFeature()
            }
            .ifLet(\.$알림함, action: \.알림함) {
                PokitAlertBoxFeature()
            }
            .ifLet(\.$링크수정, action: \.링크수정) {
                ContentSettingFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension PokitSplitFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
        case .뷰가_나타났을때:
            return .none
        case .포킷추가_버튼_눌렀을때:
            return .send(.inner(.포킷추가및수정_활성화(nil)))
        case .검색_버튼_눌렀을때:
            state.path.append(.검색(.init()))
            return .none
        case .알람_버튼_눌렀을때:
            state.알림함 = .init()
            return .none
        case .설정_버튼_눌렀을때:
            state.설정 = .init()
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_상세_활성화(category):
            state.카테고리상세 = .init(category: category)
            return .send(.카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회)))
        case let .포킷추가및수정_활성화(category):
            if let category {
                state.포킷추가및수정 = .init(
                    type: .수정,
                    categoryId: category.id,
                    categoryImage: category.categoryImage,
                    categoryName: category.categoryName
                )
            } else {
                state.포킷추가및수정 = .init(type: .추가)
            }
            return .none
        case let .링크수정_활성화(contentId):
            state.링크수정 = .init(contentId: contentId)
            return .none
        case let .링크상세_활성화(contentId):
            state.링크상세 = .init(contentId: contentId)
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
        // - MARK: 포킷
        case let .포킷(.delegate(.categoryTapped(category))):
            state.categoryId = category.id
            if Device.isPortrait {
                state.columnVisibility = .detailOnly
            }
            state.path.removeAll()
            return .send(.inner(.카테고리_상세_활성화(category)))
        case let .포킷(.delegate(.카테고리_삭제(categoryId))):
            if categoryId == state.categoryId {
                state.카테고리상세 = nil
                state.categoryId = nil
            }
            return .none
        case let .포킷(.delegate(.수정하기(category))):
            return .send(.inner(.포킷추가및수정_활성화(category)))
        case let .포킷(.delegate(.링크수정하기(id: contentId))):
            return .send(.inner(.링크수정_활성화(contentId)))
        case .포킷(.delegate(.필터_버튼_눌렀을때)):
            state.categoryId = nil
            state.카테고리상세 = nil
            return .none
        case .포킷:
            return .none
            
        // - MARK: 카테고리상세
        case let .카테고리상세(.delegate(.포킷수정(category))):
            return .send(.inner(.포킷추가및수정_활성화(category)))
        case let .카테고리상세(.delegate(.링크수정(contentId: contentId))):
            return .send(.inner(.링크수정_활성화(contentId)))
        case .카테고리상세(.delegate(.포킷삭제)):
            state.categoryId = nil
            state.카테고리상세 = nil
            return .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회)))
        case let .카테고리상세(.delegate(.contentItemTapped(contentItem))):
            return .send(.inner(.링크상세_활성화(contentItem.id)))
        case .카테고리상세(.delegate(.컨텐츠_삭제)):
            return .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회)))
        case .카테고리상세:
            return .none
            
        // - MARK: 링크추가및수정
        case .링크추가(.delegate(.dismiss)):
            state.columnVisibility = .doubleColumn
            return .none
        case .링크추가(.delegate(.저장하기_완료)):
            state.링크추가 = .init()
            return .merge(
                .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회))),
                .send(.카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회)))
            )
        case .링크추가(.delegate(.포킷추가하기)):
            state.포킷추가및수정 = .init(type: .추가)
            return .none
        case .링크추가:
            return .none
        
        // - MARK: 포킷추가및수정
        case let .포킷추가및수정(.presented(.delegate(.settingSuccess(category)))):
            var mergeEffect: [Effect<Action>] = [
                .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회))),
                .send(.포킷추가및수정(.dismiss))
            ]
            if let category {
                mergeEffect.append(.send(.inner(.카테고리_상세_활성화(category))))
            }
            return .merge(mergeEffect)
        case .포킷추가및수정:
            return .none
        
        // - MARK: 검색
        case let .검색(_, .delegate(.링크수정(contentId: contentId))):
            return .send(.inner(.링크수정_활성화(contentId)))
        case let .검색(_, .delegate(.linkCardTapped(content: content))):
            return .send(.inner(.링크상세_활성화(content.id)))
        case .검색(_, .delegate(.컨텐츠_삭제)):
            return .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회)))
        case .검색:
            return .none
        
        // - MARK: 설정
        case .설정:
            return .none
        
        // - MARK: 링크상세
        case .링크상세(.presented(.delegate(.즐겨찾기_갱신_완료))),
             .링크상세(.presented(.delegate(.컨텐츠_조회_완료))),
             .링크상세(.presented(.delegate(.컨텐츠_삭제_완료))):
            var mergeEffect: [Effect<Action>] = [
                .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회)))
            ]
            switch state.path.last {
            case .검색:
                guard let id = state.path.ids.last else { break }
                mergeEffect.append(
                    .send(.path(.element(id: id, action: .검색(.delegate(.컨텐츠_검색)))))
                )
            default:
                mergeEffect.append(.send(.카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회))))
            }
            return .merge(mergeEffect)
        case let .링크상세(.presented(.delegate(.editButtonTapped(contentId: contentId)))):
            return .send(.inner(.링크수정_활성화(contentId)))
        case .링크상세:
            return .none
            
        // - MARK: 알람
        case let .알림함(.presented(.delegate(.moveToContentEdit(id: contentId)))):
            return .send(.inner(.링크수정_활성화(contentId)))
        case .알림함(.presented(.delegate(.alertBoxDismiss))):
            return .send(.알림함(.dismiss))
        case .알림함:
            return .none
            
        // - MARK: 링크수정
        case .링크수정(.presented(.delegate(.저장하기_완료))):
            var mergeEffect: [Effect<Action>] = [
                .send(.포킷(.delegate(.미분류_카테고리_컨텐츠_조회))),
                .send(.링크수정(.dismiss))
            ]
            switch state.path.last {
            case .검색:
                guard let id = state.path.ids.last else { break }
                mergeEffect.append(
                    .send(.path(.element(id: id, action: .검색(.delegate(.컨텐츠_검색)))))
                )
            default:
                mergeEffect.append(.send(.카테고리상세(.delegate(.카테고리_내_컨텐츠_목록_조회))))
            }
            return .merge(mergeEffect)
        case .링크수정:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .링크추가_활성화:
            state.columnVisibility = .all
            return .none
        }
    }
    
    func handlePathAction(_ action: StackActionOf<Path>, state: inout State) -> Effect<Action> {
        switch action {
        case let .element(id: stackElementId, action: .검색(searchAction)):
            return .send(.scope(.검색(stackElementId, searchAction)))
        case .element, .popFrom, .push:
            return .none
        }
    }
}

extension PokitSplitFeature {
    @Reducer
    public enum Path {
        case 검색(PokitSearchFeature)
    }
}
