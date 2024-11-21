//
//  CategoryDetailFeature.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import Foundation

import ComposableArchitecture
import FeatureContentCard
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct CategoryDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(PasteboardClient.self)
    private var pasteboard
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(KakaoShareClient.self)
    private var kakaoShareClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        /// Domain
        fileprivate var domain: CategoryDetail
        var category: BaseCategoryItem {
            get { domain.category }
        }
        var isUnreadFiltered: Bool {
            get { domain.condition.isUnreadFlitered }
        }
        var isFavoriteFiltered: Bool {
            get { domain.condition.isFavoriteFlitered }
        }
        
        var sortType: SortType = .최신순
        var categories: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryListInQuiry.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var contents: IdentifiedArrayOf<ContentCardFeature.State> = []
        var kebobSelectedType: PokitDeleteBottomSheet.SheetType?
        var selectedContentItem: BaseContentItem?
        var shareSheetItem: BaseContentItem? = nil
        /// sheet Presented
        var isCategorySheetPresented: Bool = false
        var isCategorySelectSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        var isFilterSheetPresented: Bool = false
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
        }
        var isLoading: Bool = true
        
        public init(category: BaseCategoryItem) {
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
        case contents(IdentifiedActionOf<ContentCardFeature>)
        
        @CasePathable
        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case dismiss
            case pagenation
            case 카테고리_케밥_버튼_눌렀을때(PokitDeleteBottomSheet.SheetType, selectedItem: BaseContentItem?)
            case 카테고리_선택_버튼_눌렀을때
            case 카테고리_선택했을때(BaseCategoryItem)
            case 필터_버튼_눌렀을때
            case 컨텐츠_항목_눌렀을때(BaseContentItem)
            case 뷰가_나타났을때
            case 링크_공유_완료되었을때
        }
        
        public enum InnerAction: Equatable {
            case 카테고리_시트_활성화(Bool)
            case 카테고리_선택_시트_활성화(Bool)
            case 카테고리_삭제_시트_활성화(Bool)
            
            case 카테고리_목록_조회_API_반영(BaseCategoryListInquiry)
            case 카테고리_내_컨텐츠_목록_조회_API_반영(BaseContentListInquiry)
            case 컨텐츠_삭제_API_반영(id: Int)
            case pagenation_API_반영(BaseContentListInquiry)
            case pagenation_초기화
        }
        
        public enum AsyncAction: Equatable {
            case 카테고리_내_컨텐츠_목록_조회_API
            case 카테고리_목록_조회_API
            case 컨텐츠_삭제_API(id: Int)
            case 페이징_재조회
            case 클립보드_감지
        }
        
        public enum ScopeAction {
            case categoryBottomSheet(PokitBottomSheet.Delegate)
            case categoryDeleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case filterBottomSheet(CategoryFilterSheet.Delegate)
            case contents(IdentifiedActionOf<ContentCardFeature>)
        }
        
        public enum DelegateAction: Equatable {
            case contentItemTapped(BaseContentItem)
            case linkCopyDetected(URL?)
            case 링크수정(contentId: Int)
            case 포킷삭제
            case 포킷수정(BaseCategoryItem)
            case 포킷공유
            case 카테고리_내_컨텐츠_목록_조회
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
private extension CategoryDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .카테고리_케밥_버튼_눌렀을때(selectedType, selectedItem):
            state.kebobSelectedType = selectedType
            state.selectedContentItem = selectedItem
            return .run { send in await send(.inner(.카테고리_시트_활성화(true))) }
        
        case .카테고리_선택_버튼_눌렀을때:
            return .send(.inner(.카테고리_선택_시트_활성화(true)))
            
        case .카테고리_선택했을때(let item):
            state.domain.category = item
            return .run { send in
                await send(.inner(.pagenation_초기화), animation: .pokitDissolve)
                await send(.async(.카테고리_내_컨텐츠_목록_조회_API))
                await send(.inner(.카테고리_선택_시트_활성화(false)))
            }
            
        case .필터_버튼_눌렀을때:
            state.isFilterSheetPresented.toggle()
            return .none
            
        case .컨텐츠_항목_눌렀을때(let selectedItem):
            return .run { send in await send(.delegate(.contentItemTapped(selectedItem))) }
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .뷰가_나타났을때:
            /// 단순 조회 액션들의 나열이기 때문에 merge로 우선 처리
            return .merge(
                .send(.async(.카테고리_내_컨텐츠_목록_조회_API)),
                .send(.async(.카테고리_목록_조회_API)),
                .send(.async(.클립보드_감지))
            )
        case .pagenation:
            state.domain.pageable.page += 1
            return .send(.async(.카테고리_내_컨텐츠_목록_조회_API))

        case .링크_공유_완료되었을때:
            state.shareSheetItem = nil
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_시트_활성화(presented):
            state.isCategorySheetPresented = presented
            return .none
        
        case let .카테고리_삭제_시트_활성화(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none
            
        case let .카테고리_선택_시트_활성화(presented):
            state.isCategorySelectSheetPresented = presented
            return .none
            
        case let .카테고리_목록_조회_API_반영(response):
            state.domain.categoryListInQuiry = response
            guard let first = response.data?.first(where: { item in
                item.id == state.domain.category.id
            }) else { return .none }
            state.domain.category = first
            return .none
            
        case .카테고리_내_컨텐츠_목록_조회_API_반영(let contentList):
            state.domain.contentList = contentList
            
            var identifiedArray = IdentifiedArrayOf<ContentCardFeature.State>()
            contentList.data?.forEach { identifiedArray.append(.init(content: $0)) }
            state.contents = identifiedArray
            
            state.isLoading = false
            return .none
            
        case let .컨텐츠_삭제_API_반영(id):
            state.domain.contentList.data?.removeAll { $0.id == id }
            state.contents.removeAll { $0.content.id == id }
            state.domain.category.contentCount -= 1
            state.selectedContentItem = nil
            state.isPokitDeleteSheetPresented = false
            state.kebobSelectedType = nil
            return .none
        case .pagenation_API_반영(let contentList):
            let list = state.domain.contentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.contentList = contentList
            state.domain.contentList.data = list + newList
            newList.forEach { state.contents.append(.init(content: $0)) }
            return .none
            
        case .pagenation_초기화:
            state.domain.pageable.page = 0
            state.domain.contentList.data = nil
            state.isLoading = true
            state.contents.removeAll()
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_목록_조회_API:
            return .run { send in
                let request = BasePageableRequest(page: 0, size: 30, sort: ["createdAt,desc"])
                let response = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                await send(.inner(.카테고리_목록_조회_API_반영(response)))
            }
            
        case .카테고리_내_컨텐츠_목록_조회_API:
            return .run { [
                id = state.domain.category.id,
                pageable = state.domain.pageable,
                condition = state.domain.condition
            ] send in
                let request = BasePageableRequest(
                    page: pageable.page,
                    size: pageable.size,
                    sort: pageable.sort
                )
                let conditionRequest = BaseConditionRequest(categoryIds: condition.categoryIds, isRead: condition.isUnreadFlitered, favorites: condition.isFavoriteFlitered)
                let contentList = try await contentClient.카테고리_내_컨텐츠_목록_조회(
                    "\(id)", request, conditionRequest
                ).toDomain()
                pageable.page == 0
                ? await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentList)), animation: .pokitDissolve)
                : await send(.inner(.pagenation_API_반영(contentList)))
            }
            
        case let .컨텐츠_삭제_API(contentId):
            return .run { send in
                let _ = try await contentClient.컨텐츠_삭제("\(contentId)")
                await send(.inner(.컨텐츠_삭제_API_반영(id: contentId)), animation: .pokitSpring)
            }
            
        case .페이징_재조회:
            return .run { [
                pageable = state.domain.pageable,
                categoryId = state.domain.category.id,
                condition = state.domain.condition
            ] send in
                let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                    Task {
                        for page in 0...pageable.page {
                            let paeagableRequest = BasePageableRequest(
                                page: page,
                                size: pageable.size,
                                sort: pageable.sort
                            )
                            let conditionRequest = BaseConditionRequest(
                                categoryIds: condition.categoryIds,
                                isRead: condition.isUnreadFlitered,
                                favorites: condition.isFavoriteFlitered
                            )
                            let contentList = try await contentClient.카테고리_내_컨텐츠_목록_조회(
                                "\(categoryId)",
                                paeagableRequest,
                                conditionRequest
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
                await send(.inner(.카테고리_내_컨텐츠_목록_조회_API_반영(contentItems)), animation: .pokitSpring)
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
        /// - 카테고리에 대한 `공유` / `수정` / `삭제` Delegate
        case .categoryBottomSheet(let delegateAction):
            switch delegateAction {
            case .shareCellButtonTapped:
                switch state.kebobSelectedType {
                case .링크삭제:
                    state.shareSheetItem = state.selectedContentItem
                case .포킷삭제:
                    kakaoShareClient.카테고리_카카오톡_공유(
                        CategoryKaKaoShareModel(
                            categoryName: state.domain.category.categoryName,
                            categoryId: state.domain.category.id,
                            imageURL: state.domain.category.categoryImage.imageURL
                        )
                    )
                default: return .none
                }
                
                state.isCategorySheetPresented = false
                return .none
                
            case .editCellButtonTapped:
                return .run { [
                    content = state.selectedContentItem,
                    type = state.kebobSelectedType,
                    category = state.category
                ] send in
                    guard let type else { return }
                    switch type {
                    case .링크삭제:
                        guard let content else { return }
                        await send(.inner(.카테고리_시트_활성화(false)))
                        await send(.delegate(.링크수정(contentId: content.id)))
                    case .포킷삭제:
                        await send(.inner(.카테고리_시트_활성화(false)))
                        await send(.delegate(.포킷수정(category)))
                    }
                }
                
            case .deleteCellButtonTapped:
                return .run { send in
                    await send(.inner(.카테고리_시트_활성화(false)))
                    await send(.inner(.카테고리_삭제_시트_활성화(true)))
                }
                
            default: return .none
            }
        /// - 카테고리의 `삭제`를 눌렀을 때 Sheet Delegate
        case .categoryDeleteBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in await send(.inner(.카테고리_삭제_시트_활성화(false))) }
                
            case .deleteButtonTapped:
                guard let selectedType = state.kebobSelectedType else {
                    /// 🚨 Error Case [1]: 해당 타입의 항목을 삭제하려는데 선택한 `타입`이 없을 때
                    state.isPokitDeleteSheetPresented = false
                    return .none
                }
                switch selectedType {
                case .링크삭제:
                    guard let selectedItem = state.selectedContentItem else {
                    /// 🚨 Error Case [1]: 링크 타입의 항목을 삭제하려는데 선택한 `링크항목`이 없을 때
                        state.isPokitDeleteSheetPresented = false
                        return .none
                    }
                    return .send(.async(.컨텐츠_삭제_API(id: selectedItem.id)))
                case .포킷삭제:
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .run { [categoryId = state.domain.category.id] send in
                        await send(.inner(.카테고리_삭제_시트_활성화(false)))
                        await send(.delegate(.포킷삭제))
                        try await categoryClient.카테고리_삭제(categoryId)
                    }
                }
            }
        /// - 필터 버튼을 눌렀을 때
        case .filterBottomSheet(let delegateAction):
            switch delegateAction {
            case .dismiss:
                state.isFilterSheetPresented.toggle()
                return .none
            case let .확인_버튼_눌렀을때(type, bookMarkSelected, unReadSelected):
                state.isFilterSheetPresented.toggle()
                state.domain.pageable.sort = [
                    type == .최신순 ? "createdAt,desc" : "createdAt,asc"
                ]
                state.sortType = type
                state.domain.condition.isFavoriteFlitered = bookMarkSelected
                state.domain.condition.isUnreadFlitered = unReadSelected
                return .concatenate(
                    .send(.inner(.pagenation_초기화), animation: .pokitDissolve),
                    .send(.async(.카테고리_내_컨텐츠_목록_조회_API))
                )
            }
            
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_눌렀을때(content)))):
            return .send(.delegate(.contentItemTapped(content)))
        case let .contents(.element(id: _, action: .delegate(.컨텐츠_항목_케밥_버튼_눌렀을때(content)))):
            state.kebobSelectedType = .링크삭제
            state.selectedContentItem = content
            return .send(.inner(.카테고리_시트_활성화(true)))
        case .contents:
            return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_내_컨텐츠_목록_조회:
            return .send(.async(.페이징_재조회))
        default:
            return .none
        }
    }
}
