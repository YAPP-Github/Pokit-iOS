//
//  RecommendFeature.swift
//  Feature
//
//  Created by 김도형 on 1/29/25.

import SwiftUI

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct RecommendFeature {
    /// - Dependency
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(UserClient.self)
    private var userClient
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
        var interestList: IdentifiedArrayOf<BaseInterest> {
            var array = IdentifiedArrayOf<BaseInterest>()
            array.append(contentsOf: domain.interests)
            return array
        }
        var isLoading: Bool = true
        var selectedInterest: BaseInterest?
        var shareContent: BaseContentItem?
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            
            case onAppear
            case pagination
            
            case 추가하기_버튼_눌렀을때(BaseContentItem)
            case 공유하기_버튼_눌렀을때(BaseContentItem)
            case 신고하기_버튼_눌렀을때(BaseContentItem)
            case 전체보기_버튼_눌렀을때(ScrollViewProxy)
            case 관심사_버튼_눌렀을때(BaseInterest, ScrollViewProxy)
            case 링크_공유_완료되었을때
            case 검색_버튼_눌렀을때
            case 알림_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 추천_조회_API_반영(BaseContentListInquiry)
            case 추천_조회_페이징_API_반영(BaseContentListInquiry)
            case 유저_관심사_조회_API_반영([BaseInterest])
        }
        
        public enum AsyncAction: Equatable {
            case 추천_조회_API
            case 추천_조회_페이징_API
            case 유저_관심사_조회_API
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case 추가하기_버튼_눌렀을때(Int)
            case 검색_버튼_눌렀을때
            case 알림_버튼_눌렀을때
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
        BindingReducer(action: \.view)
        
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension RecommendFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding: return .none
        case .onAppear:
            return .merge(
                shared(.async(.추천_조회_API), state: &state),
                shared(.async(.유저_관심사_조회_API), state: &state)
            )
        case .pagination:
            return shared(.async(.추천_조회_페이징_API), state: &state)
        case let .추가하기_버튼_눌렀을때(content):
            return .send(.delegate(.추가하기_버튼_눌렀을때(content.id)))
        case let .공유하기_버튼_눌렀을때(content):
            state.shareContent = content
            return .none
        case let .신고하기_버튼_눌렀을때(content):
            return .none
        case let .전체보기_버튼_눌렀을때(proxy):
            guard state.selectedInterest != nil else { return .none }
            
            state.selectedInterest = nil
            proxy.scrollTo("전체보기", anchor: .leading)
            return shared(.async(.추천_조회_API), state: &state)
        case let .관심사_버튼_눌렀을때(interest, proxy):
            guard state.selectedInterest != interest else { return .none }
            
            state.selectedInterest = interest
            proxy.scrollTo(interest.description, anchor: .leading)
            return shared(.async(.추천_조회_API), state: &state)
        case .링크_공유_완료되었을때:
            state.shareContent = nil
            return .none
        case .검색_버튼_눌렀을때:
            return .send(.delegate(.검색_버튼_눌렀을때))
        case .알림_버튼_눌렀을때:
            return .send(.delegate(.알림_버튼_눌렀을때))
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
        case let .유저_관심사_조회_API_반영(interests):
            state.domain.interests = interests
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
                ),
                keyword = state.selectedInterest?.description
            ] send in
                let contentList = try await contentClient.추천_컨텐츠_조회(
                    pageableRequest,
                    keyword
                ).toDomain()
                
                await send(.inner(.추천_조회_페이징_API_반영(contentList)))
            }
        case .추천_조회_API:
            return contentListFetch(state: &state)
        case .유저_관심사_조회_API:
            return .run { send in
                let interests = try await userClient.유저_관심사_목록_조회().map { $0.toDomian() }
                await send(.inner(.유저_관심사_조회_API_반영(interests)))
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
            pageable = state.domain.pageable,
            keyword = state.selectedInterest?.description
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
                            pageableRequest,
                            keyword
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
