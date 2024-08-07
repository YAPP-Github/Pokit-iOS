//
//  PokitSearchFeature.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct PokitSearchFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pasteboard) var pasteboard
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() { }
        @Presents
        var filterBottomSheet: FilterBottomFeature.State?
        
        var searchText: String = ""
        var recentSearchTexts: [String] = [
            "샤프 노트북",
            "아이패드",
            "맥북",
            "LG 그램",
            "LG 그램1",
            "LG 그램2",
            "LG 그램3",
            "LG 그램4",
            "LG 그램5",
            "LG 그램6",
            "LG 그램7"
        ]
        var isAutoSaveSearch: Bool = false
        var isSearching: Bool = false
        var isFiltered: Bool = false
        var categoryFilter = IdentifiedArrayOf<BaseCategory>()
        var contentTypeText = "모아보기"
        var dateFilterText = "기간"
        var isResultAscending = true
        
        fileprivate var domain = Search()
        var resultMock: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.contentList.data.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var favoriteFilter: Bool {
            get { domain.condition.favorites }
            set { domain.condition.favorites = newValue }
        }
        var unreadFilter: Bool {
            get { !domain.condition.isRead }
            set { domain.condition.isRead = !newValue }
        }
        var startDateFilter: Date? {
            get { domain.condition.startDate }
            set { domain.condition.startDate = newValue }
        }
        var endDateFilter: Date? {
            get { domain.condition.endDate }
            set { domain.condition.endDate = newValue }
        }
        
        /// sheet item
        var bottomSheetItem: BaseContent? = nil
        var alertItem: BaseContent? = nil
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case fiterBottomSheet(PresentationAction<FilterBottomFeature.Action>)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case autoSaveButtonTapped
            case searchTextInputIconTapped
            case searchTextChipButtonTapped(text: String)
            case filterButtonTapped
            case contentTypeFilterButtonTapped
            case dateFilterButtonTapped
            case categoryFilterButtonTapped
            case categoryFilterChipTapped(category: BaseCategory)
            case recentSearchAllRemoveButtonTapped
            case recentSearchChipIconTapped(searchText: String)
            case linkCardTapped(content: BaseContent)
            case kebabButtonTapped(content: BaseContent)
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
            case deleteAlertConfirmTapped(content: BaseContent)
            case sortTextLinkTapped
            case backButtonTapped
            /// - TextInput OnSubmitted
            case searchTextInputOnSubmitted
            
            case onAppear
            
        }
        
        public enum InnerAction: Equatable {
            case enableIsSearching
            case disableIsSearching
            case updateDateFilter(startDate: Date?, endDate: Date?)
            case showFilterBottomSheet(filterType: FilterBottomFeature.FilterType)
            case updateContentTypeFilter(favoriteFilter: Bool, unreadFilter: Bool)
            case dismissBottomSheet
            case updateIsFiltered
            case updateCategoryIds
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case filterBottomSheet(FilterBottomFeature.Action.DelegateAction)
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContent
            )
        }
        
        public enum DelegateAction: Equatable {
            case linkCardTapped(content: BaseContent)
            case bottomSheetEditCellButtonTapped(content: BaseContent)
            case linkCopyDetected(URL?)
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
        case .fiterBottomSheet(.presented(.delegate(let delegate))):
            return .send(.scope(.filterBottomSheet(delegate)))
        case .fiterBottomSheet:
            return .none
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .ifLet(\.$filterBottomSheet, action: \.fiterBottomSheet) {
                FilterBottomFeature()
            }
    }
}

//MARK: - FeatureAction Effect
private extension PokitSearchFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.searchText):
            guard !state.searchText.isEmpty else {
                /// 🚨 Error Case [1]: 빈 문자열 일 때
                return .send(.inner(.disableIsSearching))
            }
            return .none
        case .binding:
            return .none
        case .autoSaveButtonTapped:
            state.isAutoSaveSearch.toggle()
            return .none
        case .searchTextInputOnSubmitted:
            return .run { send in
                // - TODO: 검색 조회
                await send(.inner(.enableIsSearching))
            }
        case .searchTextInputIconTapped:
            /// - 검색 중일 경우 `문자열 지우기 버튼 동작`
            if state.isSearching {
                state.searchText = ""
                return .send(.inner(.disableIsSearching))
            } else {
                return .run { send in
                    // - TODO: 검색 조회
                    await send(.inner(.enableIsSearching))
                }
            }
        case .searchTextChipButtonTapped(text: let text):
            state.searchText = text
            return .run { send in
                // - TODO: 검색 조회
                await send(.inner(.enableIsSearching))
            }
        case .filterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .pokit)))
        case .contentTypeFilterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .contentType)))
        case .dateFilterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .date)))
        case .categoryFilterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .pokit)))
        case .recentSearchAllRemoveButtonTapped:
            state.recentSearchTexts.removeAll()
            return .none
        case .recentSearchChipIconTapped(searchText: let searchText):
            guard let predicate = state.recentSearchTexts.firstIndex(of: searchText) else {
                return .none
            }
            state.recentSearchTexts.remove(at: predicate)
            return .none
        case .linkCardTapped(content: let content):
            return .send(.delegate(.linkCardTapped(content: content)))
        case .kebabButtonTapped(content: let content):
            state.bottomSheetItem = content
            return .none
        case .bottomSheetButtonTapped(delegate: let delegate, content: let content):
            return .run { send in
                await send(.inner(.dismissBottomSheet))
                await send(.scope(.bottomSheet(delegate: delegate, content: content)))
            }
        case .deleteAlertConfirmTapped(content: let content):
            state.alertItem = nil
            return .none
        case .sortTextLinkTapped:
            state.isResultAscending.toggle()
            // - TODO: 정렬
            return .none
        case .backButtonTapped:
            return .run { _ in
                await dismiss()
            }
            
        case .onAppear:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        case .categoryFilterChipTapped(category: let category):
            state.categoryFilter.remove(category)
            return .send(.inner(.updateCategoryIds))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .enableIsSearching:
            state.isSearching = true
            // - MARK: 더미 조회
            state.domain.contentList = ContentListInquiryResponse.mock.toDomain()
            return .none
        case .disableIsSearching:
            state.isSearching = false
            return .none
        case .updateDateFilter(startDate: let startDate, endDate: let endDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd"
            
            state.startDateFilter = startDate
            state.endDateFilter = endDate
            
            guard let startDate, let endDate else {
                /// - 날짜 필터가 선택 안되었을 경우
                state.dateFilterText = "기간"
                return .none
            }
            
            if startDate == endDate {
                /// - 날짜 필터를 하루만 선택했을 경우
                state.dateFilterText = "\(formatter.string(from: startDate))"
            } else {
                state.dateFilterText = "\(formatter.string(from: startDate))~\(formatter.string(from: endDate))"
            }
            
            return .none
        case .showFilterBottomSheet(filterType: let filterType):
            state.filterBottomSheet = .init(
                filterType: filterType,
                pokitFilter: state.categoryFilter,
                favoriteFilter: state.favoriteFilter,
                unreadFilter: state.unreadFilter,
                startDateFilter: state.startDateFilter,
                endDateFilter: state.endDateFilter
            )
            return .none
        case .updateContentTypeFilter(favoriteFilter: let favoriteFilter, unreadFilter: let unreadFilter):
            state.favoriteFilter = favoriteFilter
            state.unreadFilter = unreadFilter
            
            if favoriteFilter && unreadFilter {
                /// - 즐겨찾기, 안읽음 모두 선택
                state.contentTypeText = "즐겨찾기, 안읽음"
            } else if favoriteFilter {
                /// - 즐겨찾기만 선택
                state.contentTypeText = "즐겨찾기"
            } else if unreadFilter {
                /// - 안읽음만 선택
                state.contentTypeText = "안읽음"
            } else {
                state.contentTypeText = "모아보기"
            }
            return .none
        case .dismissBottomSheet:
            state.bottomSheetItem = nil
            return .none
        case .updateIsFiltered:
            state.isFiltered = !state.categoryFilter.isEmpty ||
            state.favoriteFilter ||
            state.unreadFilter ||
            state.startDateFilter != nil ||
            state.endDateFilter != nil
            return .none
        case .updateCategoryIds:
            state.domain.condition.categoryIds = state.categoryFilter.map { $0.id }
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
        case .filterBottomSheet(.searchButtonTapped(
            categories: let categories,
            isFavorite: let isFavorite,
            isUnread: let isUnread,
            startDate: let startDate,
            endDate: let endDate)):
            state.categoryFilter = categories
            return .run { send in
                await send(.inner(.updateCategoryIds))
                await send(.inner(.updateContentTypeFilter(favoriteFilter: isFavorite, unreadFilter: isUnread)))
                await send(.inner(.updateDateFilter(startDate: startDate, endDate: endDate)))
                await send(.inner(.updateIsFiltered))
                // - TODO: 검색 조회
            }
        case .bottomSheet(let delegate, let content):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = content
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.bottomSheetEditCellButtonTapped(content: content)))
            case .favoriteCellButtonTapped:
                return .none
            case .shareCellButtonTapped:
                return .none
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
