//
//  PokitLinkEditFeature.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import ComposableArchitecture
import CoreKit
import Domain
import DSKit
import FeatureCategorySetting
import Util

@Reducer
public struct PokitLinkEditFeature {
    /// - Dependency
    @Dependency(\.dismiss) 
    var dismiss
    @Dependency(CategoryClient.self) 
    var categoryClient
    @Dependency(ContentClient.self) 
    var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        @Presents var addPokit: PokitCategorySettingFeature.State?
        /// 링크 아이템 Doamin
        var item: BaseContentListInquiry
        /// 카테고리 아이템 Domain
        var category: BaseCategoryListInquiry?
        /// 링크 목록
        var list = IdentifiedArrayOf<BaseContentItem>()
        /// 선택한 링크 목록
        var selectedItems = IdentifiedArrayOf<BaseContentItem>()
        var isActive: Bool = false
        /// 포킷 이동 눌렀을 때 sheet
        var categorySelectSheetPresetend: Bool = false
        var linkDeleteSheetPresented: Bool = false
        var linkPopup: PokitLinkPopup.PopupType?
        
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
            
            case 뷰가_나타났을때
            case 포킷_추가하기_버튼_눌렀을때
            case 링크팝업_버튼_눌렀을때
            case 경고시트_해제
            case 삭제확인_버튼_눌렀을때
            case 체크박스_선택했을때(BaseContentItem)
            case 카테고리_선택했을때(BaseCategoryItem)
        }
        
        public enum InnerAction {
            case error(Error)
            case 카테고리_이동_시트_활성화(Bool)
            case 카테고리_삭제_시트_활성화(Bool)
            case 경고팝업_활성화(PokitLinkPopup.PopupType)
            case 카테고리_목록_조회_API_반영(BaseCategoryListInquiry)
            case 미분류_API_반영(LinkEditType)
        }
        
        public enum AsyncAction: Equatable { case 없음 }
        
        @CasePathable
        public enum ScopeAction {
            case floatButtonAction(PokitLinkEditFloatView.Delegate)
            case addPokit(PresentationAction<PokitCategorySettingFeature.Action>)
        }
        
        public enum DelegateAction: Equatable {
            case 링크_편집_종료(items: [BaseContentItem], type: LinkEditType)
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
            .ifLet(\.$addPokit, action: \.scope.addPokit) {
                PokitCategorySettingFeature()
            }
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
            return .send(.delegate(.링크_편집_종료(items: state.list.elements, type: .dismiss)))
            
        case .뷰가_나타났을때:
            return fetchCateogryList()
            
        case .포킷_추가하기_버튼_눌렀을때:
            state.categorySelectSheetPresetend = false
            state.linkDeleteSheetPresented = false
            state.addPokit = PokitCategorySettingFeature.State(type: .추가)
            return .none
            
        case .경고시트_해제:
            return .send(.inner(.카테고리_삭제_시트_활성화(false)))
            
        case .삭제확인_버튼_눌렀을때:
            return linkDelete(state: &state)
            
        case let .체크박스_선택했을때(item):
            /// 이미 체크되어 있다면 해제
            if state.selectedItems.contains(item) {
                state.selectedItems.remove(id: item.id)
            } else {
                state.selectedItems.append(item)
            }
            
            state.isActive = !state.selectedItems.isEmpty
            return .none
            
        case let .카테고리_선택했을때(pokit):
            /// 🚨 Error Case [1]: 체크한 것이 없는데 카테고리를 선택했을 때
            if state.selectedItems.isEmpty {
                return .merge(
                    .send(.inner(.카테고리_이동_시트_활성화(false))),
                    .send(.inner(.경고팝업_활성화(.error(title: "링크를 선택해주세요."))))
                )
            } else {
                return moveContentList(category: pokit, state: &state)
            }
            
        case .링크팝업_버튼_눌렀을때:
            state.linkPopup = nil
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .error(error):
            guard let errorResponse = error as? ErrorResponse else { return .none }
            state.categorySelectSheetPresetend = false
            state.linkDeleteSheetPresented = false
            return .merge(
                .send(.inner(.카테고리_이동_시트_활성화(false))),
                .send(.inner(.카테고리_삭제_시트_활성화(false))),
                .send(.inner(.경고팝업_활성화(.error(title: errorResponse.message))),
                      animation: .pokitSpring
                )
            )
            
        case let .경고팝업_활성화(type):
            state.linkPopup = type
            return .none
            
        case let .카테고리_이동_시트_활성화(isPresented):
            state.categorySelectSheetPresetend = isPresented
            return .none
            
        case let .카테고리_삭제_시트_활성화(isPresented):
            state.linkDeleteSheetPresented = isPresented
            return .none
            
        case let .카테고리_목록_조회_API_반영(response):
            state.category = response
            return .none
            
        case let .미분류_API_반영(type):
            /// 1. 시트 내리기
            if case .링크이동 = type {
                state.categorySelectSheetPresetend = false
            } else {
                state.linkDeleteSheetPresented = false
            }
            /// 2. 선택했던 체크리스트 삭제
            state.selectedItems
                .map { $0.id }
                .forEach { state.list.remove(id: $0) }
            state.selectedItems.removeAll()
            /// 3. 분류가 남은 링크가 없을 때  편집하기 종료
            if state.list.isEmpty {
                return .send(.delegate(.링크_편집_종료(items: [], type: type)))
            }
            /// 4. 링크이동을 했을 때 바텀 메세지 출력
            if case let .링크이동(categoryName) = type {
                state.linkPopup = .text(title: "\(categoryName)\n카테고리로 이동되었습니다.")
                return .none
            }
            
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
                if state.selectedItems.isEmpty {
                    return .send(.inner(.경고팝업_활성화(.error(title: "링크를 선택해주세요."))))
                } else {
                    return .send(.inner(.카테고리_삭제_시트_활성화(true)))
                }
                
            case .전체선택_버튼_눌렀을때:
                state.selectedItems = state.list
                return .none
                
            case .전체해제_버튼_눌렀을때:
                state.selectedItems.removeAll()
                return .none
                
            case .포킷이동_버튼_눌렀을때:
                return .send(.inner(.카테고리_이동_시트_활성화(true)))
            }
            
        case .addPokit(.presented(.delegate(.settingSuccess))):
            state.addPokit = nil
            return .merge(
                fetchCateogryList(),
                .send(.inner(.카테고리_이동_시트_활성화(true)))
            )
            
        case .addPokit:
            return .none
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
            let response = try await categoryClient.카테고리_목록_조회(request, true, true).toDomain()
            await send(.inner(.카테고리_목록_조회_API_반영(response)))
        }
    }
    
    /// 미분류 링크 카테고리 이동 API
    func moveContentList(category: BaseCategoryItem, state: inout State) -> Effect<Action> {
        return .run { [contentIds = state.selectedItems] send in
            let contentIds = contentIds.map { $0.id }
            let request = ContentMoveRequest(contentIds: contentIds, categoryId: category.id)
            try await contentClient.미분류_링크_포킷_이동(request)
            await send(.inner(.미분류_API_반영(.링크이동)))
        } catch: { error, send in
            await send(.inner(.error(error)))
        }
    }
    
    func linkDelete(state: inout State) -> Effect<Action> {
        return .run { [contentIds = state.selectedItems.ids] send in
            let request = ContentDeleteRequest(contentId: Array(contentIds))
            try await contentClient.미분류_링크_삭제(request)
            await send(.inner(.미분류_API_반영(.링크삭제)))
        } catch: { error, send in
            await send(.inner(.error(error)))
        }
    }
}
public extension PokitLinkEditFeature {
    enum LinkEditType: Equatable {
        case dismiss
        case 링크이동
        case 링크삭제
    }
}
