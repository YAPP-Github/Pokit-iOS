//
//  FilterBottomFeature.swift
//  Feature
//
//  Created by 김도형 on 7/27/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct FilterBottomFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(CategoryClient.self)
    private var categoryClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(
            filterType currentType: FilterType,
            pokitFilter selectedPokit: IdentifiedArrayOf<BaseCategoryItem>,
            favoriteFilter isFavorite: Bool,
            unreadFilter isUnread: Bool,
            startDateFilter startDate: Date?,
            endDateFilter endDate: Date?
        ) {
            self.currentType = currentType
            self.selectedCategories = selectedPokit
            self.isFavorite = isFavorite
            self.isUnread = isUnread
            self.dateSelected = startDate != nil || endDate != nil
            self.startDate = startDate ?? .now
            self.endDate = endDate ?? .now
        }
        
        var currentType: FilterType
        
        var selectedCategories = IdentifiedArrayOf<BaseCategoryItem>()
        var isFavorite: Bool
        var isUnread: Bool
        var dateSelected: Bool
        var startDate: Date
        var endDate: Date
        var startDateText: String {
            let fomatter = DateFormat.dateFilter.formatter
            return fomatter.string(from: startDate)
        }
        var endDateText: String {
            let fomatter = DateFormat.dateFilter.formatter
            return fomatter.string(from: endDate)
        }
        
        fileprivate var domain = FilterBottom()
        var pokitList: [BaseCategoryItem]? {
            get { domain.categoryList.data }
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
            /// - Binding
            case binding(BindingAction<State>)
            case 포킷_항목_눌렀을때(pokit: BaseCategoryItem)
            case 검색하기_버튼_눌렀을때
            case 포킷_태그_눌렀을때(BaseCategoryItem)
            case 즐겨찾기_태그_눌렀을때
            case 안읽음_태그_눌렀을때
            case 기간_태그_눌렀을때
            case 즐겨찾기_체크박스_눌렀을때
            case 안읽음_체크박스_눌렀을때
            case 뷰가_나타났을때
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_목록_조회_API_반영(categoryList: BaseCategoryListInquiry)
        }
        
        public enum AsyncAction: Equatable {
            case 카테고리_목록_조회_API
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case 검색_버튼_눌렀을때(
                categories: IdentifiedArrayOf<BaseCategoryItem>,
                isFavorite: Bool,
                isUnread: Bool,
                startDate: Date?,
                endDate: Date?
            )
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
private extension FilterBottomFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.startDate):
                state.dateSelected = true
            return .none
            
        case .binding(\.endDate):
                state.dateSelected = true
            return .none
            
        case .binding:
            return .none
            
        case .포킷_항목_눌렀을때(let pokit):
            state.selectedCategories.append(pokit)
            return .none
            
        case .검색하기_버튼_눌렀을때:
            return .run { [
                categories = state.selectedCategories,
                isFavorite = state.isFavorite,
                isUnread = state.isUnread,
                startDate = state.startDate,
                endDate = state.endDate,
                dateSelected = state.dateSelected
            ] send in
                await send(.delegate(.검색_버튼_눌렀을때(
                    categories: categories,
                    isFavorite: isFavorite,
                    isUnread: isUnread,
                    startDate: dateSelected ? startDate : nil,
                    endDate: dateSelected ? endDate : nil
                )))
                await dismiss()
            }
            
        case .포킷_태그_눌렀을때(let category):
            state.selectedCategories.remove(category)
            return .none
            
        case .즐겨찾기_태그_눌렀을때:
            state.isFavorite = false
            return .none
            
        case .안읽음_태그_눌렀을때:
            state.isUnread = false
            return .none
            
        case .기간_태그_눌렀을때:
            state.startDate = .now
            state.endDate = .now
            state.dateSelected = false
            return .none
            
        case .즐겨찾기_체크박스_눌렀을때:
            state.isFavorite.toggle()
            return .none
            
        case .안읽음_체크박스_눌렀을때:
            state.isUnread.toggle()
            return .none
            
        case .뷰가_나타났을때:
            return .send(.async(.카테고리_목록_조회_API))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_목록_조회_API_반영(categoryList):
            state.domain.categoryList = categoryList
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_목록_조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let categoryList = try await categoryClient.카테고리_목록_조회(
                    BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    ),
                    true
                ).toDomain()
                await send(.inner(.카테고리_목록_조회_API_반영(categoryList: categoryList)), animation: .pokitDissolve)
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

public extension FilterBottomFeature {
    enum FilterType {
        case pokit
        case contentType
        case date
    }
}
