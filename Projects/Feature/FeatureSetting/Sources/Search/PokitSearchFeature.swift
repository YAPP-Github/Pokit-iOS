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
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.mainQueue)
    private var mainQueue
    @Dependency(\.pasteboard)
    private var pasteboard
    @Dependency(\.userDefaults)
    private var userDefaults
    @Dependency(\.contentClient)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() { }
        @Presents
        var filterBottomSheet: FilterBottomFeature.State?
        
        var recentSearchTexts: [String] = []
        var isAutoSaveSearch: Bool = false
        var isSearching: Bool = false
        var isFiltered: Bool = false
        var categoryFilter = IdentifiedArrayOf<BaseCategoryItem>()
        var dateFilterText = "기간"
        var isResultAscending = true
        
        fileprivate var domain = Search()
        var searchText: String {
            get { domain.condition.searchWord }
            set { domain.condition.searchWord = newValue }
        }
        var resultMock: IdentifiedArrayOf<BaseContentItem>? {
            guard let contentList = domain.contentList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            contentList.forEach { identifiedArray.append($0) }
            return identifiedArray
        }
        var favoriteFilter: Bool {
            get { domain.condition.favorites }
            set { domain.condition.favorites = newValue }
        }
        var unreadFilter: Bool {
            get { domain.condition.isRead }
            set { domain.condition.isRead = newValue }
        }
        var startDateFilter: Date? {
            get { domain.condition.startDate }
            set { domain.condition.startDate = newValue }
        }
        var endDateFilter: Date? {
            get { domain.condition.endDate }
            set { domain.condition.endDate = newValue }
        }
        var startDateString: String? {
            guard let startDate = domain.condition.startDate else {
                return nil
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            return formatter.string(from: startDate)
        }
        
        /// sheet item
        var bottomSheetItem: BaseContentItem? = nil
        var alertItem: BaseContentItem? = nil
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
            case favoriteChipTapped
            case unreadChipTapped
            case dateFilterButtonTapped
            case categoryFilterButtonTapped
            case categoryFilterChipTapped(category: BaseCategoryItem)
            case recentSearchAllRemoveButtonTapped
            case recentSearchChipIconTapped(searchText: String)
            case linkCardTapped(content: BaseContentItem)
            case kebabButtonTapped(content: BaseContentItem)
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
            case deleteAlertConfirmTapped
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
            case 컨텐츠_목록_갱신(BaseContentListInquiry)
            case 최근검색어_불러오기
            case 자동저장_켜기_불러오기
            case 최근검색어_추가
            case 컨텐츠_삭제_반영(id: Int)
        }
        
        public enum AsyncAction: Equatable {
            case 컨텐츠_검색
            case 최근검색어_갱신
            case 자동저장_켜기_갱신
            case 컨텐츠_삭제(id: Int)
        }
        
        public enum ScopeAction: Equatable {
            case filterBottomSheet(FilterBottomFeature.Action.DelegateAction)
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
        }
        
        public enum DelegateAction: Equatable {
            case linkCardTapped(content: BaseContentItem)
            case 링크수정(contentId: Int)
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
    public enum CancelID { case response }
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
            return .send(.async(.자동저장_켜기_갱신))
        case .searchTextInputOnSubmitted:
            return .run { send in
                await send(.inner(.최근검색어_추가))
                await send(.async(.컨텐츠_검색))
            }
        case .searchTextInputIconTapped:
            /// - 검색 중일 경우 `문자열 지우기 버튼 동작`
            if state.isSearching {
                state.domain.condition.searchWord = ""
                return .send(.inner(.disableIsSearching))
            } else {
                return .run { send in
                    await send(.inner(.최근검색어_추가))
                    await send(.async(.컨텐츠_검색))
                }
            }
        case .searchTextChipButtonTapped(text: let text):
            state.searchText = text
            return .send(.async(.컨텐츠_검색))
        case .filterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .pokit)))
        case .contentTypeFilterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .contentType)))
        case .dateFilterButtonTapped:
            guard state.domain.condition.startDate != nil && state.domain.condition.endDate != nil else {
                /// - 선택된 기간이 없을 경우
                return .send(.inner(.showFilterBottomSheet(filterType: .date)))
            }
            state.domain.condition.startDate = nil
            state.domain.condition.endDate = nil
            return .run { send in
                await send(.inner(.updateDateFilter(startDate: nil, endDate: nil)))
                await send(.async(.컨텐츠_검색))
            }
        case .categoryFilterButtonTapped:
            return .send(.inner(.showFilterBottomSheet(filterType: .pokit)))
        case .recentSearchAllRemoveButtonTapped:
            state.recentSearchTexts.removeAll()
            return .send(.async(.최근검색어_갱신))
        case .recentSearchChipIconTapped(searchText: let searchText):
            guard let predicate = state.recentSearchTexts.firstIndex(of: searchText) else {
                return .none
            }
            state.recentSearchTexts.remove(at: predicate)
            return .send(.async(.최근검색어_갱신))
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
        case .deleteAlertConfirmTapped:
            guard let id = state.alertItem?.id else { return .none }
            state.alertItem = nil
            return .run { [id] send in
                await send(.async(.컨텐츠_삭제(id: id)))
            }
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
                await send(.inner(.자동저장_켜기_불러오기))
                await send(.inner(.최근검색어_불러오기))
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        case .categoryFilterChipTapped(category: let category):
            state.categoryFilter.remove(category)
            return .run { send in
                await send(.inner(.updateCategoryIds))
                await send(.async(.컨텐츠_검색))
            }
        case .favoriteChipTapped:
            state.domain.condition.favorites = false
            return .send(.async(.컨텐츠_검색))
        case .unreadChipTapped:
            state.domain.condition.isRead = false
            return .send(.async(.컨텐츠_검색))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .enableIsSearching:
            state.isSearching = true
            return .none
        case .disableIsSearching:
            state.isSearching = false
            state.domain.contentList.data = []
            return .none
        case .updateDateFilter(startDate: let startDate, endDate: let endDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd"
            
            state.domain.condition.startDate = startDate
            state.domain.condition.endDate = endDate
            
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
            state.domain.condition.favorites = favoriteFilter
            state.domain.condition.isRead = unreadFilter
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
        case .컨텐츠_목록_갱신(let contentList):
            state.domain.contentList = contentList
            return .send(.inner(.enableIsSearching))
        case .최근검색어_불러오기:
            guard state.isAutoSaveSearch else {
                return .none
            }
            state.recentSearchTexts = userDefaults.stringArrayKey(.searchWords) ?? []
            return .none
        case .자동저장_켜기_불러오기:
            state.isAutoSaveSearch = userDefaults.boolKey(.autoSaveSearch)
            return .none
            
        case .최근검색어_추가:
            guard state.isAutoSaveSearch else {
                return .none
            }
            if !state.recentSearchTexts.contains(state.domain.condition.searchWord) {
                state.recentSearchTexts.append(state.domain.condition.searchWord)
            }
            return .send(.async(.최근검색어_갱신))
        case .컨텐츠_삭제_반영(id: let id):
            state.alertItem = nil
            state.domain.contentList.data?.removeAll { $0.id == id }
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_검색:
            state.domain.contentList.data = nil
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            var startDateString: String? = nil
            var endDateString: String? = nil
            if let startDate = state.domain.condition.startDate {
                startDateString = formatter.string(from: startDate)
            }
            if let endDate = state.domain.condition.endDate {
                endDateString = formatter.string(from: endDate)
            }
            return .run { [
                pageable = state.domain.pageable,
                condition = state.domain.condition,
                startDateString,
                endDateString
            ] send in
                let contentList = try await contentClient.컨텐츠_검색(
                    .init(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    ),
                    .init(
                        categoryIds: condition.categoryIds,
                        isRead: condition.isRead,
                        favorites: condition.favorites,
                        startDate: startDateString,
                        endDate: endDateString
                    )
                ).toDomain()
                await send(.inner(.컨텐츠_목록_갱신(contentList)), animation: .smooth)
            }
        case .최근검색어_갱신:
            guard state.isAutoSaveSearch else {
                return .none
            }
            return .run { [ searchWords = state.recentSearchTexts ] _ in
                await userDefaults.setStringArray(
                    searchWords,
                    .searchWords
                )
            }
        case .자동저장_켜기_갱신:
            return .run { [
                isAutoSaveSearch = state.isAutoSaveSearch
            ] send in
                await userDefaults.setBool(isAutoSaveSearch, .autoSaveSearch)
            }
        case .컨텐츠_삭제(id: let id):
            return .run { [id] send in
                let _ = try await contentClient.컨텐츠_삭제("\(id)")
                await send(.inner(.컨텐츠_삭제_반영(id: id)), animation: .pokitSpring)
            }
        }
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
                await send(.async(.컨텐츠_검색))
            }
        case .bottomSheet(let delegate, let content):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = content
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.링크수정(contentId: content.id)))
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
