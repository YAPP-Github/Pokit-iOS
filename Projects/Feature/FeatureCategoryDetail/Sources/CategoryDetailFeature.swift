//
//  CategoryDetailFeature.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct CategoryDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pasteboard) var pasteboard
    /// - State
    @ObservableState
    public struct State: Equatable {
        /// Domain
        fileprivate var domain: CategoryDetail
        var category: BaseCategory {
            get { domain.category }
        }
        var categories: IdentifiedArrayOf<BaseCategory> {
            var identifiedArray = IdentifiedArrayOf<BaseCategory>()
            domain.categoryListInQuiry.data.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var contents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.contentList.data.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }
        var kebobSelectedType: PokitDeleteBottomSheet.SheetType?
        var selectedLinkItem: BaseContent?
        /// sheet Presented
        var isCategorySheetPresented: Bool = false
        var isCategorySelectSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        var isFilterSheetPresented: Bool = false
        
        public init(category: BaseCategory) {
            self.domain = .init(categpry: category)
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
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case categoryKebobButtonTapped(PokitDeleteBottomSheet.SheetType, selectedItem: BaseContent?)
            case categorySelectButtonTapped
            case categorySelected(BaseCategory)
            case filterButtonTapped
            case linkItemTapped(BaseContent)
            case dismiss
            case onAppear
        }
        
        public enum InnerAction: Equatable {
            case pokitCategorySheetPresented(Bool)
            case pokitCategorySelectSheetPresented(Bool)
            case pokitDeleteSheetPresented(Bool)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case categoryBottomSheet(PokitBottomSheet.Delegate)
            case categoryDeleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case filterBottomSheet(CategoryFilterSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            case linkItemTapped(BaseContent)
            case linkCopyDetected(URL?)
            case 링크수정(BaseContent)
            case 포킷삭제
            case 포킷수정(BaseCategory)
            case 포킷공유
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
private extension CategoryDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .categoryKebobButtonTapped(selectedType, selectedItem):
            state.kebobSelectedType = selectedType
            state.selectedLinkItem = selectedItem
            return .run { send in await send(.inner(.pokitCategorySheetPresented(true))) }
        
        case .categorySelectButtonTapped:
            return .send(.inner(.pokitCategorySelectSheetPresented(true)))
            
        case .categorySelected(let item):
            /// Todo: 아이템 선택한 것 반영
            return .send(.inner(.pokitCategorySelectSheetPresented(false)))
            
        case .filterButtonTapped:
            state.isFilterSheetPresented.toggle()
            return .none
            
        case .linkItemTapped(let selectedItem):
            return .run { send in await send(.delegate(.linkItemTapped(selectedItem))) }
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .onAppear:
            // - MARK: 목업 데이터 조회
            state.domain.categoryListInQuiry = CategoryListInquiryResponse.mock.toDomain()
            state.domain.contentList = ContentListInquiryResponse.mock.toDomain()
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .pokitCategorySheetPresented(presented):
            state.isCategorySheetPresented = presented
            return .none
        
        case let .pokitDeleteSheetPresented(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none
            
        case let .pokitCategorySelectSheetPresented(presented):
            state.isCategorySelectSheetPresented = presented
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
        /// - 카테고리에 대한 `공유` / `수정` / `삭제` Delegate
        case .categoryBottomSheet(let delegateAction):
            switch delegateAction {
            case .shareCellButtonTapped:
                return .none
                
            case .editCellButtonTapped:
                return .run { [
                    link = state.selectedLinkItem,
                    type = state.kebobSelectedType,
                    category = state.category
                ] send in
                    guard let type else { return }
                    switch type {
                    case .링크삭제:
                        guard let link else { return }
                        await send(.inner(.pokitCategorySheetPresented(false)))
                        await send(.delegate(.링크수정(link)))
                    case .포킷삭제:
                        await send(.inner(.pokitCategorySheetPresented(false)))
                        await send(.delegate(.포킷수정(category)))
                    }
                }
                
            case .deleteCellButtonTapped:
                return .run { send in
                    await send(.inner(.pokitCategorySheetPresented(false)))
                    await send(.inner(.pokitDeleteSheetPresented(true)))
                }
                
            default: return .none
            }
        /// - 카테고리의 `삭제`를 눌렀을 때 Sheet Delegate
        case .categoryDeleteBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in await send(.inner(.pokitDeleteSheetPresented(false))) }
                
            case .deleteButtonTapped:
                guard let selectedType = state.kebobSelectedType else {
                    /// 🚨 Error Case [1]: 해당 타입의 항목을 삭제하려는데 선택한 `타입`이 없을 때
                    state.isPokitDeleteSheetPresented = false
                    return .none
                }
                switch selectedType {
                case .링크삭제:
                    guard let selectedItem = state.selectedLinkItem else {
                    /// 🚨 Error Case [1]: 링크 타입의 항목을 삭제하려는데 선택한 `링크항목`이 없을 때
                        state.isPokitDeleteSheetPresented = false
                        return .none
                    }
                    guard let index = state.domain.contentList.data.firstIndex(of: selectedItem) else {
                        return .none
                    }
                    state.domain.contentList.data.remove(at: index)
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .none
                    
                case .포킷삭제:
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .send(.delegate(.포킷삭제))
                }
            }
        /// - 필터 버튼을 눌렀을 때
        case .filterBottomSheet(let delegateAction):
            switch delegateAction {
            case .dismissButtonTapped:
                state.isFilterSheetPresented.toggle()
                return .none
            case let .okButtonTapped(type, bookMarkSelected, unReadSelected):
                state.isFilterSheetPresented.toggle()
                return .none
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
