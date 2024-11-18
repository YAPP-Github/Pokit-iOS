//
//  CategorySharingFeature.swift
//  Feature
//
//  Created by 김도형 on 8/21/24.

import Foundation

import ComposableArchitecture
import FeatureContentCard
import Domain
import CoreKit
import Util

@Reducer
public struct CategorySharingFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(ContentClient.self)
    private var contentClient

    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain: CategorySharing
        var category: CategorySharing.Category { domain.sharedCategory.category }
        var contents: IdentifiedArrayOf<ContentCardFeature.State> = []
        var hasNext: Bool { domain.sharedCategory.contentList.hasNext }
        var error: BaseError?
        var isErrorSheetPresented: Bool = false
        var isLoading: Bool = true
        
        public init(sharedCategory: CategorySharing.SharedCategory) {
            domain = .init(
                sharedCategory: sharedCategory,
                pageable: BasePageable(
                    page: 0,
                    size: 10,
                    sort: ["desc"]
                )
            )
        }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case contents(IdentifiedActionOf<ContentCardFeature>)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            case dismiss
            
            case 저장_버튼_눌렀을때
            case 경고_확인버튼_눌렀을때
            case 페이지_로딩중일때
            case 뷰가_나타났을때
        }
        
        public enum InnerAction: Equatable {
            case 공유받은_카테고리_API_반영(CategorySharing.SharedCategory)
            case 경고_닫음
            case 경고_띄움(BaseError)
        }
        
        public enum AsyncAction: Equatable {
            case 공유받은_카테고리_조회_API
        }
        
        public enum ScopeAction {
            case contents(IdentifiedActionOf<ContentCardFeature>)
        }
        
        public enum DelegateAction: Equatable {
            case 컨텐츠_아이템_클릭(categoryId: Int, content: CategorySharing.Content)
            case 공유받은_카테고리_추가(sharedCategory: CategorySharing.Category)
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
            
        case .contents(let contentsAction):
            return .send(.scope(.contents(contentsAction)))
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .forEach(\.contents, action: \.contents) {
                ContentCardFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension CategorySharingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .저장_버튼_눌렀을때:
            let sharedCategory = state.domain.sharedCategory.category
            return .send(.delegate(.공유받은_카테고리_추가(sharedCategory: sharedCategory)))
            
        case .경고_확인버튼_눌렀을때:
            return .none
            
        case .페이지_로딩중일때:
            return .send(.async(.공유받은_카테고리_조회_API))
        case .뷰가_나타났을때:
            state.domain.sharedCategory.contentList.data.forEach { content in
                state.contents.append(.init(content: .init(
                    id: content.id,
                    categoryName: content.categoryName,
                    categoryId: state.category.categoryId,
                    title: content.title,
                    thumbNail: content.thumbNail,
                    data: content.data,
                    domain: content.domain,
                    createdAt: content.createdAt,
                    isRead: content.isRead
                )))
            }
            state.isLoading = false
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .공유받은_카테고리_API_반영(sharedCategory):
            state.domain.sharedCategory = sharedCategory
            
            sharedCategory.contentList.data.forEach { content in
                state.contents.append(.init(content: .init(
                    id: content.id,
                    categoryName: content.categoryName,
                    categoryId: state.category.categoryId,
                    title: content.title,
                    thumbNail: content.thumbNail,
                    data: content.data,
                    domain: content.domain,
                    createdAt: content.createdAt,
                    isRead: content.isRead
                )))
            }
            state.isLoading = false
            return .none
            
        case let .경고_띄움(baseError):
            state.error = baseError
            state.isErrorSheetPresented = true
            return .none
            
        case .경고_닫음:
            state.isErrorSheetPresented = false
            state.error = nil
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .공유받은_카테고리_조회_API:
            state.domain.pageable.page += 1
            return .run { [
                categoryId = state.domain.sharedCategory.category.categoryId,
                pageable = state.domain.pageable
            ] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let sharedCategory = try await categoryClient.공유받은_카테고리_조회(
                    "\(categoryId)",
                    request
                ).toDomain()
                await send(.inner(.공유받은_카테고리_API_반영(sharedCategory)), animation: .pokitDissolve)
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_눌렀을때(content)))):
            let sharedContent = state.domain.sharedCategory.contentList.data.first { item in
                item.id == content.id
            }
            guard let sharedContent else { return .none }
            
            return .send(.delegate(.컨텐츠_아이템_클릭(
                categoryId: state.category.categoryId,
                content: sharedContent
            )))
        case .contents:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
