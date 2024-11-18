//
//  PokitSearchFeature.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import Foundation

import ComposableArchitecture
import FeatureContentCard
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
    @Dependency(PasteboardClient.self)
    private var pasteboard
    @Dependency(UserDefaultsClient.self)
    private var userDefaults
    @Dependency(ContentClient.self)
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
        var isResultAscending = false
        
        fileprivate var domain = Search()
        var searchText: String {
            get { domain.condition.searchWord }
            set { domain.condition.searchWord = newValue }
        }
        var contents: IdentifiedArrayOf<ContentCardFeature.State> = []
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
            guard let startDate = domain.condition.startDate else { return nil}
            let formatter = DateFormat.searchCondition.formatter
            return formatter.string(from: startDate)
        }
        var hasNext: Bool {
            get { domain.contentList.hasNext }
        }
        var isLoading: Bool = false
        
        /// sheet item
        var bottomSheetItem: BaseContentItem? = nil
        var alertItem: BaseContentItem? = nil
        var shareSheetItem: BaseContentItem? = nil
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case fiterBottomSheet(PresentationAction<FilterBottomFeature.Action>)
        case contents(IdentifiedActionOf<ContentCardFeature>)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            case dismiss
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
            case 자동저장_버튼_눌렀을때
            case 검색_버튼_눌렀을때
            case 최근검색_태그_눌렀을때(text: String)
            case 최근검색_태그_삭제_눌렀을때(searchText: String)
            case 필터링_버튼_눌렀을때
            case 카테고리_버튼_눌렀을때
            case 모아보기_버튼_눌렀을때
            case 기간_버튼_눌렀을때
            case 카테고리_태그_눌렀을때(category: BaseCategoryItem)
            case 즐겨찾기_태그_눌렀을때
            case 안읽음_태그_눌렀을때
            case 전체_삭제_버튼_눌렀을때
            case 컨텐츠_항목_눌렀을때(content: BaseContentItem)
            case 컨텐츠_항목_케밥_버튼_눌렀을때(content: BaseContentItem)
            case 정렬_버튼_눌렀을때
            case 검색_키보드_엔터_눌렀을때
            case 링크_삭제_눌렀을때
            case 링크_공유_완료되었을때
            case 뷰가_나타났을때
            case 로딩중일때
            
        }
        
        public enum InnerAction: Equatable {
            case filterBottomSheet(filterType: FilterBottomFeature.FilterType)
            case 검색창_활성화(Bool)
            case 기간_업데이트(startDate: Date?, endDate: Date?)
            case 모아보기_업데이트(favoriteFilter: Bool, unreadFilter: Bool)
            case 필터_업데이트
            case 카테고리_ID_목록_업데이트
            case 바텀시트_해제
            case 컨텐츠_검색_API_반영(BaseContentListInquiry)
            case 컨텐츠_검색_페이징_API_반영(BaseContentListInquiry)
            case 컨텐츠_삭제_API_반영(id: Int)
            case 최근검색어_불러오기
            case 자동저장_불러오기
            case 최근검색어_추가
            case 페이징_초기화
        }
        
        public enum AsyncAction: Equatable {
            case 컨텐츠_검색_API
            case 최근검색어_갱신_수행
            case 자동저장_수행
            case 컨텐츠_삭제_API(id: Int)
            case 컨텐츠_검색_페이징_API
            case 클립보드_감지
        }
        
        public enum ScopeAction {
            case filterBottomSheet(FilterBottomFeature.Action.DelegateAction)
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                content: BaseContentItem
            )
            case contents(IdentifiedActionOf<ContentCardFeature>)
        }
        
        public enum DelegateAction: Equatable {
            case linkCardTapped(content: BaseContentItem)
            case 링크수정(contentId: Int)
            case linkCopyDetected(URL?)
            case 컨텐츠_검색
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
            
        case .contents(let contentsAction):
            return .send(.scope(.contents(contentsAction)))
        }
    }
    public enum CancelID { case response }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .forEach(\.contents, action: \.contents) {
                ContentCardFeature()
            }
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
                /// 🚨 Error Case: 빈 문자열 일 때
                return .send(.inner(.검색창_활성화(false)))
            }
            return .none
            
        case .binding:
            return .none
            
        case .자동저장_버튼_눌렀을때:
            state.isAutoSaveSearch.toggle()
            return .send(.async(.자동저장_수행))
            
        case .검색_키보드_엔터_눌렀을때:
            return .run { send in
                await send(.inner(.최근검색어_추가))
                await send(.inner(.페이징_초기화), animation: .pokitDissolve)
            }
            
        case .검색_버튼_눌렀을때:
            /// - 검색 중일 경우 `문자열 지우기 버튼 동작`
            if state.isSearching {
                state.domain.condition.searchWord = ""
                return .send(.inner(.검색창_활성화(false)))
            } else {
                return .run { send in
                    await send(.inner(.최근검색어_추가))
                    await send(.inner(.페이징_초기화), animation: .pokitDissolve)
                }
            }
            
        case let .최근검색_태그_눌렀을때(text):
            state.searchText = text
            return .send(.inner(.페이징_초기화), animation: .pokitDissolve)
            
        case .필터링_버튼_눌렀을때:
            return .send(.inner(.filterBottomSheet(filterType: .pokit)))
            
        case .모아보기_버튼_눌렀을때:
            return .send(.inner(.filterBottomSheet(filterType: .contentType)))
            
        case .기간_버튼_눌렀을때:
            guard state.domain.condition.startDate != nil && state.domain.condition.endDate != nil else {
                /// - 선택된 기간이 없을 경우
                return .send(.inner(.filterBottomSheet(filterType: .date)))
            }
            state.domain.condition.startDate = nil
            state.domain.condition.endDate = nil
            return .run { send in
                await send(.inner(.기간_업데이트(startDate: nil, endDate: nil)))
                await send(.inner(.페이징_초기화), animation: .pokitDissolve)
            }
            
        case .카테고리_버튼_눌렀을때:
            return .send(.inner(.filterBottomSheet(filterType: .pokit)))
            
        case .전체_삭제_버튼_눌렀을때:
            state.recentSearchTexts.removeAll()
            return .send(.async(.최근검색어_갱신_수행))
            
        case let .최근검색_태그_삭제_눌렀을때(searchText):
            guard let predicate = state.recentSearchTexts.firstIndex(of: searchText) else {
                return .none
            }
            state.recentSearchTexts.remove(at: predicate)
            return .send(.async(.최근검색어_갱신_수행))
            
        case let .컨텐츠_항목_눌렀을때(content):
            return .send(.delegate(.linkCardTapped(content: content)))
            
        case let .컨텐츠_항목_케밥_버튼_눌렀을때(content):
            state.bottomSheetItem = content
            return .none
            
        case .bottomSheet(delegate: let delegate, content: let content):
            return .run { send in
                await send(.inner(.바텀시트_해제))
                await send(.scope(.bottomSheet(delegate: delegate, content: content)))
            }
            
        case .링크_삭제_눌렀을때:
            guard let id = state.alertItem?.id else { return .none }
            state.alertItem = nil
            return .send(.async(.컨텐츠_삭제_API(id: id)))
            
        case .정렬_버튼_눌렀을때:
            state.isResultAscending.toggle()
            state.domain.pageable.sort = [
                state.isResultAscending ? "createdAt,asc" : "createdAt,desc"
            ]
            return .send(.inner(.페이징_초기화))
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .뷰가_나타났을때:
            let contentList = state.domain.contentList.data
            
            var effectBox: [Effect<Action>] = [
                .send(.inner(.자동저장_불러오기)),
                .send(.inner(.최근검색어_불러오기)),
                .send(.async(.클립보드_감지))
            ]
            
            if let contentList, !contentList.isEmpty {
                effectBox.append(.send(.async(.컨텐츠_검색_API)))
            }
            
            return .merge(effectBox)
            
        case let .카테고리_태그_눌렀을때(category):
            state.categoryFilter.remove(category)
            return .run { send in
                await send(.inner(.카테고리_ID_목록_업데이트))
                await send(.inner(.페이징_초기화))
            }
            
        case .즐겨찾기_태그_눌렀을때:
            state.domain.condition.favorites = false
            return .send(.inner(.페이징_초기화))
            
        case .안읽음_태그_눌렀을때:
            state.domain.condition.isRead = false
            return .send(.inner(.페이징_초기화))
            
        case .링크_공유_완료되었을때:
            state.shareSheetItem = nil
            return .none

        case .로딩중일때:
            return .send(.async(.컨텐츠_검색_페이징_API))
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .검색창_활성화(isActive):
            if isActive {
                state.isSearching = true
            } else {
                state.isSearching = false
                state.domain.contentList.data = []
            }
            return .none
            
        case let .기간_업데이트(startDate, endDate):
            let formatter = DateFormat.dateFilter.formatter
            
            state.domain.condition.startDate = startDate
            state.domain.condition.endDate = endDate
            
            guard let startDate,
                  let endDate else {
                /// 🚨 Error Case : 날짜 필터가 선택 안되었을 경우
                state.dateFilterText = "기간"
                return .none
            }
            state.dateFilterText = startDate == endDate
            ? "\(formatter.string(from: startDate))" /// - 날짜 필터를 하루만 선택했을 경우
            : "\(formatter.string(from: startDate))~\(formatter.string(from: endDate))"
            return .none
            
        case let .filterBottomSheet(filterType):
            state.filterBottomSheet = .init(
                filterType: filterType,
                pokitFilter: state.categoryFilter,
                favoriteFilter: state.favoriteFilter,
                unreadFilter: state.unreadFilter,
                startDateFilter: state.startDateFilter,
                endDateFilter: state.endDateFilter
            )
            return .none
            
        case let .모아보기_업데이트(favoriteFilter, unreadFilter):
            state.domain.condition.favorites = favoriteFilter
            state.domain.condition.isRead = unreadFilter
            return .none
            
        case .바텀시트_해제:
            state.bottomSheetItem = nil
            return .none
            
        case .필터_업데이트:
            state.isFiltered = !state.categoryFilter.isEmpty
            || state.favoriteFilter
            || state.unreadFilter
            || state.startDateFilter != nil
            || state.endDateFilter != nil
            return .none
            
        case .카테고리_ID_목록_업데이트:
            state.domain.condition.categoryIds = state.categoryFilter.map { $0.id }
            return .none
            
        case .컨텐츠_검색_API_반영(let contentList):
            state.domain.contentList = contentList
            
            var contents = IdentifiedArrayOf<ContentCardFeature.State>()
            contentList.data?.forEach { contents.append(.init(content: $0)) }
            state.contents = contents
            state.isLoading = false
            return .send(.inner(.검색창_활성화(true)))
            
        case .최근검색어_불러오기:
            guard state.isAutoSaveSearch else { return .none }
            state.recentSearchTexts = userDefaults.stringArrayKey(.searchWords) ?? []
            return .none
            
        case .자동저장_불러오기:
            state.isAutoSaveSearch = userDefaults.boolKey(.autoSaveSearch)
            return .none
            
        case .최근검색어_추가:
            let searchWord = state.domain.condition.searchWord
            guard state.isAutoSaveSearch && !searchWord.isEmpty else {
                /// 🚨 Error Case: 검색어 자동저장이 `off`거나, 검색 키워드가 없다면 종료
                return .none
            }
            
            if !state.recentSearchTexts.contains(searchWord) {
                state.recentSearchTexts.append(searchWord)
            }
            return .send(.async(.최근검색어_갱신_수행))
            
        case let .컨텐츠_삭제_API_반영(id):
            state.alertItem = nil
            state.domain.contentList.data?.removeAll { $0.id == id }
            state.contents.removeAll { $0.content.id == id }
            return .none
            
        case let .컨텐츠_검색_페이징_API_반영(contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            
            newList.forEach { state.contents.append(.init(content: $0)) }
            
            return .send(.inner(.검색창_활성화(true)))
            
        case .페이징_초기화:
            state.domain.pageable.page = 0
            state.domain.contentList.data = nil
            state.isLoading = true
            state.contents.removeAll()
            return .send(.async(.컨텐츠_검색_API), animation: .pokitDissolve)
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_검색_API:
            return contentSearch(state: &state)
            
        case .최근검색어_갱신_수행:
            guard state.isAutoSaveSearch else { return .none }
            return .run { [ searchWords = state.recentSearchTexts ] _ in
                await userDefaults.setStringArray(
                    searchWords,
                    .searchWords
                )
            }
            
        case .자동저장_수행:
            return .run { [isAutoSaveSearch = state.isAutoSaveSearch] _ in
                await userDefaults.setBool(isAutoSaveSearch, .autoSaveSearch)
            }
            
        case let .컨텐츠_삭제_API(id):
            return .run { send in
                let _ = try await contentClient.컨텐츠_삭제("\(id)")
                await send(.inner(.컨텐츠_삭제_API_반영(id: id)), animation: .pokitSpring)
            }
            
        case .컨텐츠_검색_페이징_API:
            state.domain.pageable.page += 1
            let formatter = DateFormat.yearMonthDate.formatter
            
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
                let pageableRequest = BasePageableRequest(
                    page: pageable.page,
                    size: pageable.size,
                    sort: pageable.sort
                )
                
                let conditionRequest = BaseConditionRequest(
                    searchWord: condition.searchWord,
                    categoryIds: condition.categoryIds,
                    isRead: condition.isRead,
                    favorites: condition.favorites,
                    startDate: startDateString,
                    endDate: endDateString
                )
                
                let contentList = try await contentClient.컨텐츠_검색(
                    pageableRequest,
                    conditionRequest
                ).toDomain()
                
                await send(.inner(.컨텐츠_검색_페이징_API_반영(contentList)))
            }

        case .클립보드_감지:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
        
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .filterBottomSheet(.검색_버튼_눌렀을때(
            categories: let categories,
            isFavorite: let isFavorite,
            isUnread: let isUnread,
            startDate: let startDate,
            endDate: let endDate)):
            state.categoryFilter = categories
            return .run { send in
                await send(.inner(.카테고리_ID_목록_업데이트))
                await send(.inner(.모아보기_업데이트(favoriteFilter: isFavorite, unreadFilter: isUnread)))
                await send(.inner(.기간_업데이트(startDate: startDate, endDate: endDate)))
                await send(.inner(.필터_업데이트))
                await send(.inner(.페이징_초기화))
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
                state.shareSheetItem = content
                return .none
            }
            
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_눌렀을때(content)))):
            return .send(.delegate(.linkCardTapped(content: content)))
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content)))):
            state.bottomSheetItem = content
            return .none
        case .contents:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_검색:
            guard let contentList = state.domain.contentList.data, !contentList.isEmpty else {
                return .none
            }
            return .send(.async(.컨텐츠_검색_API), animation: .pokitSpring)
        default: return .none
        }
    }
    
    func contentSearch(state: inout State) -> Effect<Action> {
        let formatter = DateFormat.yearMonthDate.formatter
        
        var startDateString: String? = nil
        var endDateString: String? = nil
        if let startDate = state.domain.condition.startDate {
            startDateString = formatter.string(from: startDate)
        }
        if let endDate = state.domain.condition.endDate {
            endDateString = formatter.string(from: endDate)
        }
        let condition = BaseConditionRequest(
            searchWord: state.domain.condition.searchWord,
            categoryIds: state.domain.condition.categoryIds,
            isRead: state.domain.condition.isRead,
            favorites: state.domain.condition.favorites,
            startDate: startDateString,
            endDate: endDateString
        )
        
        return .run { [pageable = state.domain.pageable, condition] send in
            let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                Task {
                    for page in 0...pageable.page {
                        let request = BasePageableRequest(
                            page: page,
                            size: pageable.size,
                            sort: pageable.sort
                        )
                        let contentList = try await contentClient.컨텐츠_검색(request, condition).toDomain()
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
            await send(.inner(.컨텐츠_검색_API_반영(contentItems)), animation: .pokitSpring)
        }
    }
}
