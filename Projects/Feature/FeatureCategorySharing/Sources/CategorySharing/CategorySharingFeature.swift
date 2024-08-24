//
//  CategorySharingFeature.swift
//  Feature
//
//  Created by 김도형 on 8/21/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct CategorySharingFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.categoryClient)
    private var categoryClient
    @Dependency(\.contentClient)
    private var contentClient

    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain: CategorySharing
        var category: CategorySharing.Category {
            get { domain.sharedCategory.category }
        }
        var contents: IdentifiedArrayOf<CategorySharing.Content>? {
            var identifiedArray = IdentifiedArrayOf<CategorySharing.Content>()
            domain.sharedCategory.contentList.data.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }
        var hasNext: Bool {
            get { domain.sharedCategory.contentList.hasNext }
        }
        var alert: CategorySharing.Alert? {
            get { domain.alert }
            set { domain.alert = newValue }
        }
        
        public init(sharedCategory: CategorySharing.SharedCategory) {
            domain = .init(
                sharedCategory: sharedCategory,
                pageable: .init(
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
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case 저장버튼_클릭
            case 컨텐츠_아이템_클릭(CategorySharing.Content)
            case 뒤로가기버튼_클릭
            case 경고_확인버튼_클릭
            
            case 다음페이지_로딩_onAppear
            
            case binding(BindingAction<State>)
        }
        
        public enum InnerAction: Equatable {
            case 공유받은_카테고리_갱신(CategorySharing.SharedCategory)
            case 경고_띄움(titleKey: String, message: String)
        }
        
        public enum AsyncAction: Equatable {
            case 공유받은_카테고리_조회
            case 공유받은_카테고리_저장
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case 컨텐츠_아이템_클릭(categoryId: Int, content: CategorySharing.Content)
            case 공유받은_카테고리_저장(categoryName: String)
            case 공유받은_카테고리_수정(categoryName: String)
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
private extension CategorySharingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .저장버튼_클릭:
            return .send(.async(.공유받은_카테고리_저장))
        case let .컨텐츠_아이템_클릭(content):
            return .send(.delegate(.컨텐츠_아이템_클릭(categoryId: state.category.categoryId , content: content)))
        case .뒤로가기버튼_클릭:
            return .run { _ in await dismiss() }
        case .경고_확인버튼_클릭:
            switch state.alert?.titleKey {
            case "포킷 저장 오류":
                state.alert = nil
                return .run { _ in await dismiss() }
            case "포킷명을 변경하시겠습니까?":
                state.alert = nil
                let categoryName = state.domain.sharedCategory.category.categoryName
                return .send(.delegate(.공유받은_카테고리_수정(categoryName: categoryName)))
            default: return .none
            }
        case .binding:
            return .none
        case .다음페이지_로딩_onAppear:
            return .send(.async(.공유받은_카테고리_조회))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .공유받은_카테고리_갱신(sharedCategory):
            state.domain.sharedCategory = sharedCategory
            state.domain.copiedCategory = .init(
                originCategoryId: sharedCategory.category.categoryId,
                categoryName: sharedCategory.category.categoryName
            )
            return .none
        case let .경고_띄움(titleKey: titleKey, message: message):
            state.alert = .init(titleKey: titleKey, message: message)
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .공유받은_카테고리_조회:
            return .run { [
                categoryId = state.domain.sharedCategory.category.categoryId,
                pageable = state.domain.pageable
            ] send in
                let sharedCategory = try await categoryClient.공유받은_카테고리_조회(
                    "\(categoryId)",
                    .init(
                        page: pageable.page + 1,
                        size: pageable.size,
                        sort: pageable.sort
                    )
                ).toDomain()
                await send(.inner(.공유받은_카테고리_갱신(sharedCategory)), animation: .smooth)
            }
        case .공유받은_카테고리_저장:
            return .run { [
                copiedCategory = state.domain.copiedCategory
            ] _ in
                try await categoryClient.공유받은_카테고리_저장(
                    .init(
                        originCategoryId: copiedCategory.originCategoryId,
                        categoryName: copiedCategory.categoryName
                    )
                )
                await dismiss()
            } catch: { error, send in
                guard let errorResponse = error as? ErrorResponse else {
                    return
                }
                switch errorResponse.code {
                case "C_008":
                    await send(.inner(.경고_띄움(
                        titleKey: "포킷 저장 오류",
                        message: errorResponse.message
                    )))
                case "C_009":
                    await send(.inner(.경고_띄움(
                        titleKey:  "포킷명을 변경하시겠습니까?",
                        message: errorResponse.message
                    )))
                default:
                    print(error)
                    return
                }
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .공유받은_카테고리_저장(categoryName: categoryName):
            state.domain.copiedCategory.categoryName = categoryName
            return .send(.async(.공유받은_카테고리_저장))
        default: return .none
        }
    }
}