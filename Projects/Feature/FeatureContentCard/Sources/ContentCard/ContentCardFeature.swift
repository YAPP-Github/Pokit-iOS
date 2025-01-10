//
//  LinkCardFeature.swift
//  Feature
//
//  Created by 김도형 on 11/17/24.

import SwiftUI

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct ContentCardFeature {
    /// - Dependency
    @Dependency(SwiftSoupClient.self)
    private var swiftSoupClient
    @Dependency(\.openURL)
    private var openURL
    @Dependency(ContentClient.self)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id = UUID()
        public var content: BaseContentItem
        
        public init(content: BaseContentItem) {
            self.content = content
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
        public enum View: Equatable {
            case 컨텐츠_항목_눌렀을때
            case 컨텐츠_항목_케밥_버튼_눌렀을때
            case 즐겨찾기_버튼_눌렀을때
            case 메타데이터_조회
        }
        
        public enum InnerAction: Equatable {
            case 메타데이터_조회_수행_반영(String)
            case 즐겨찾기_API_반영(Bool)
        }
        
        public enum AsyncAction: Equatable {
            case 메타데이터_조회_수행
            case 즐겨찾기_API
            case 즐겨찾기_취소_API
            case 썸네일_수정_API
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case 컨텐츠_항목_케밥_버튼_눌렀을때(content: BaseContentItem)
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
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension ContentCardFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_항목_눌렀을때:
            guard let url = URL(string: state.content.data) else {
                return .none
            }
            return .run {  _ in await openURL(url) }
        case .컨텐츠_항목_케밥_버튼_눌렀을때:
            return shared(
                .delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content: state.content)),
                state: &state
            )
        case .메타데이터_조회:
            return shared(.async(.메타데이터_조회_수행), state: &state)
        case .즐겨찾기_버튼_눌렀을때:
            guard let isFavorite = state.content.isFavorite else {
                return .none
            }
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
            return isFavorite
            ? shared(.async(.즐겨찾기_취소_API), state: &state)
            : shared(.async(.즐겨찾기_API), state: &state)
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .메타데이터_조회_수행_반영(imageURL):
            state.content.thumbNail = imageURL
            return shared(.async(.썸네일_수정_API), state: &state)
        case .즐겨찾기_API_반영(let favorite):
            state.content.isFavorite = favorite
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .메타데이터_조회_수행:
            guard let url = URL(string: state.content.data) else {
                return .none
            }
            return .run { send in
                let imageURL = try await swiftSoupClient.parseOGImageURL(url)
                guard let imageURL else { return }
                await send(.inner(.메타데이터_조회_수행_반영(imageURL)))
            }
        case .즐겨찾기_API:
            return .run { [id = state.content.id] send in
                let _ = try await contentClient.즐겨찾기("\(id)")
                await send(.inner(.즐겨찾기_API_반영(true)), animation: .pokitDissolve)
            }
        case .즐겨찾기_취소_API:
            return .run { [id = state.content.id] send in
                try await contentClient.즐겨찾기_취소("\(id)")
                await send(.inner(.즐겨찾기_API_반영(false)), animation: .pokitDissolve)
            }
        case .썸네일_수정_API:
            return .run { [content = state.content] _ in
                let request = ThumbnailRequest(thumbnail: content.thumbNail)
                
                try await contentClient.썸네일_수정(
                    contentId: "\(content.id)",
                    model: request
                )
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    func shared(_ action: Action, state: inout State) -> Effect<Action> {
        switch action {
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
}
