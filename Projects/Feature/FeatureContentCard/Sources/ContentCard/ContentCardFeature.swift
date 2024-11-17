//
//  LinkCardFeature.swift
//  Feature
//
//  Created by 김도형 on 11/17/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct ContentCardFeature {
    /// - Dependency
    @Dependency(SwiftSoupClient.self)
    private var swiftSoupClient
    /// - State
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id = UUID()
        var content: BaseContentItem
        
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
            case 메타데이터_조회
        }
        
        public enum InnerAction: Equatable {
            case 메타데이터_조회_수행_반영(String)
        }
        
        public enum AsyncAction: Equatable {
            case 메타데이터_조회_수행
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case 컨텐츠_항목_눌렀을때(content: BaseContentItem)
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
            return .send(.delegate(.컨텐츠_항목_눌렀을때(content: state.content)))
        case .컨텐츠_항목_케밥_버튼_눌렀을때:
            return .send(.delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content: state.content)))
        case .메타데이터_조회:
            return .send(.async(.메타데이터_조회_수행))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .메타데이터_조회_수행_반영(imageURL):
            state.content.thumbNail = imageURL
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
                let imageURL = try await swiftSoupClient.parseOGImageURL(url: url)
                guard let imageURL else { return }
                await send(.inner(.메타데이터_조회_수행_반영(imageURL)))
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
}
