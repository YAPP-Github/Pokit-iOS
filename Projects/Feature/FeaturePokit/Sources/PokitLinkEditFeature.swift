//
//  PokitLinkEditFeature.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import ComposableArchitecture
import CoreKit
import Domain
import Util

@Reducer
public struct PokitLinkEditFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(CategoryClient.self) var categoryClient
    @Dependency(ContentClient.self) var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        /// 링크 아이템 Doamin
        var item: BaseContentListInquiry
        /// 카테고리 아이템 Domain
        var category: BaseCategoryListInquiry?
        /// 링크 목록
        var list = IdentifiedArrayOf<BaseContentItem>()
        /// 선택한 링크 목록
        var selectedItems = IdentifiedArrayOf<BaseContentItem>()
        /// 포킷 이동 눌렀을 때 sheet
        var isPresented: Bool = false
        
        public init(linkList: BaseContentListInquiry) {
            self.item = linkList
            if let data = self.item.data {
                data.forEach { list.append($0) }
            }
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
        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case dismiss
            case onAppear
            
            case 카테고리_추가_버튼_눌렀을때
            case 체크박스_선택했을때(BaseContentItem)
            case 카테고리_선택했을때(BaseCategoryItem)
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_목록_조회_API_반영(BaseCategoryListInquiry)
            case 미분류_카테고리_이동_API_반영
        }
        
        public enum AsyncAction: Equatable { case 없음 }
        
        public enum ScopeAction: Equatable {
            case floatButtonAction(PokitLinkEditFloatView.Delegate)
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
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension PokitLinkEditFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .onAppear:
            return fetchCateogryList()
            
        case .카테고리_추가_버튼_눌렀을때:
            return .none
            
        case let .체크박스_선택했을때(item):
            /// 이미 체크되어 있다면 해제
            if state.selectedItems.contains(item) {
                state.selectedItems.remove(id: item.id)
            } else {
                state.selectedItems.append(item)
            }
            return .none
            
        case let .카테고리_선택했을때(pokit):
            return moveContentList(categoryId: pokit.id, state: &state)
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_목록_조회_API_반영(response):
            state.category = response
            return .none
            
        case .미분류_카테고리_이동_API_반영:
            /// 1. 시트 내리기
            state.isPresented = false
            /// 2. 선택했던 체크리스트 삭제
            state.selectedItems
                .map { $0.id }
                .forEach { state.list.remove(id: $0) }
            state.selectedItems.removeAll()
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
        case let .floatButtonAction(delegate):
            switch delegate {
            case .링크삭제_버튼_눌렀을때:
                return .none
                
            case .전체선택_버튼_눌렀을때:
                state.selectedItems = state.list
                return .none
                
            case .전체해제_버튼_눌렀을때:
                state.selectedItems.removeAll()
                return .none
                
            case .포킷이동_버튼_눌렀을때:
                state.isPresented = true
                return .none
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// 카테고리 목록 조회 API
    func fetchCateogryList() -> Effect<Action> {
        return .run { send in
            let request: BasePageableRequest = BasePageableRequest(page: 0, size: 100, sort: ["createdAt", "desc"])
            let response = try await categoryClient.카테고리_목록_조회(model: request, filterUncategorized: false).toDomain()
            await send(.inner(.카테고리_목록_조회_API_반영(response)))
        }
    }
    
    /// 미분류 링크 카테고리 이동 API
    func moveContentList(categoryId: Int, state: inout State) -> Effect<Action> {
        return .run { [contentIds = state.selectedItems] send in
            let contentIds = contentIds.map { $0.id }
            let request = ContentMoveRequest(contentIds: contentIds, categoryId: categoryId)
            try await contentClient.미분류_링크_포킷_이동(request)
            await send(.inner(.미분류_카테고리_이동_API_반영))
        }
    }
}
