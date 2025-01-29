//
//  RecommendFeature.swift
//  Feature
//
//  Created by 김도형 on 1/29/25.

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct RecommendFeature {
    /// - Dependency
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(PasteboardClient.self)
    private var pasteBoard
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        fileprivate var domain = Recommend()
        var isListDescending = true
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
        }
        var recommendedList: IdentifiedArrayOf<BaseContentItem>? {
            guard let list = domain.contentList.data else { return nil }
            var array = IdentifiedArrayOf<BaseContentItem>()
            array.append(contentsOf: list)
            return array
        }
        var isLoading: Bool = true
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
            case onAppear
            case pagination
        }
        
        public enum InnerAction: Equatable {
            case 추천_조회_API_반영(BaseContentListInquiry)
            case 추천_조회_페이징_API_반영(BaseContentListInquiry)
        }
        
        public enum AsyncAction: Equatable {
            case 추천_조회_API
            case 추천_조회_페이징_API
        }
        
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
private extension RecommendFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return shared(.async(.추천_조회_API), state: &state)
        case .pagination:
            return shared(.async(.추천_조회_페이징_API), state: &state)
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .추천_조회_페이징_API_반영(let contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            return .none
        case .추천_조회_API_반영(let contentList):
            state.domain.contentList = contentList
            
            state.isLoading = false
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .추천_조회_페이징_API:
            state.domain.pageable.page += 1
            return .run { [
                pageableRequest = BasePageableRequest(
                    page: state.domain.pageable.page,
                    size: state.domain.pageable.size,
                    sort: state.domain.pageable.sort
                )
            ] send in
                let contentList = try await contentClient.추천_컨텐츠_조회(
                    model: pageableRequest
                ).toDomain()
                
                await send(.inner(.추천_조회_페이징_API_반영(contentList)))
            }
        case .추천_조회_API:
            return contentListFetch(state: &state)
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
    
    /// - Shared Effect
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
    
    func contentListFetch(state: inout State) -> Effect<Action> {
        return .run { [
            pageable = state.domain.pageable
        ] send in
            let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                Task {
                    for page in 0...pageable.page {
                        let pageableRequest = BasePageableRequest(
                            page: page,
                            size: pageable.size,
                            sort: pageable.sort
                        )
                        let contentList = try await contentClient.추천_컨텐츠_조회(
                            model: pageableRequest
                        ).toDomain()
                        continuation.yield(contentList)
                    }
                    continuation.finish()
                }
            }
            var contentItems: BaseContentListInquiry? = nil
            for try await contentList in stream {
                let items = contentItems?.data ?? []
                let newItems = contentList.data ?? []
                contentItems = contentList
                contentItems?.data = items + newItems
            }
            guard let contentItems else { return }
            await send(.inner(.추천_조회_API_반영(contentItems)), animation: .pokitDissolve)
        }
    }
}
