//
//  PokitRootFeature.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct PokitRootFeature {
    /// - Dependency
    @Dependency(CategoryClient.self)
    private var categoryClient
    @Dependency(ContentClient.self)
    private var contentClient
    @Dependency(KakaoShareClient.self)
    private var kakaoShareClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)

        fileprivate var domain = Pokit()
        var categories: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var unclassifiedContents: IdentifiedArrayOf<BaseContentItem>? {
            guard let unclassifiedContentList = domain.unclassifiedContentList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            unclassifiedContentList.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }

        var selectedKebobItem: BaseCategoryItem?
        var selectedUnclassifiedItem: BaseContentItem?
        var shareSheetItem: BaseContentItem? = nil

        var isKebobSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        
        var hasNext: Bool { domain.categoryList.hasNext }
        var unclassifiedHasNext: Bool { domain.unclassifiedContentList.hasNext }

        public init() { }
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
            case 검색_버튼_눌렀을때
            case 알람_버튼_눌렀을때
            case 설정_버튼_눌렀을때
            case 필터_버튼_눌렀을때(PokitRootFilterType.Folder)
            case 분류_버튼_눌렀을때
            case 케밥_버튼_눌렀을때(BaseCategoryItem)
            case 미분류_케밥_버튼_눌렀을때(BaseContentItem)
            case 카테고리_눌렀을때(BaseCategoryItem)
            case 컨텐츠_항목_눌렀을때(BaseContentItem)
            case 링크_공유_완료되었을때
            case 뷰가_나타났을때
            case 페이지_로딩중일때
        }

        public enum InnerAction: Equatable {
            case sort
            case 카테고리_시트_활성화(Bool)
            case 카테고리_삭제_시트_활성화(Bool)
            
            case 미분류_카테고리_조회_API_반영(contentList: BaseContentListInquiry)
            case 미분류_카테고리_페이징_조회_API_반영(contentList: BaseContentListInquiry)
            case 미분류_카테고리_컨텐츠_삭제_API_반영(contentId: Int)
            
            case 카테고리_조회_API_반영(categoryList: BaseCategoryListInquiry)
            case 카테고리_페이징_조회_API_반영(contentList: BaseCategoryListInquiry)
            
            case 페이지네이션_초기화
        }

        public enum AsyncAction: Equatable {
            case 카테고리_조회_API
            case 카테고리_페이징_조회_API
            case 카테고리_페이징_재조회_API
            case 카테고리_삭제_API(categoryId: Int)
            
            case 미분류_카테고리_조회_API
            case 미분류_카테고리_페이징_조회_API
            case 미분류_카테고리_페이징_재조회_API
            case 미분류_카테고리_컨텐츠_삭제_API(contentId: Int)
        }

        public enum ScopeAction: Equatable {
            case bottomSheet(PokitBottomSheet.Delegate)
            case deleteBottomSheet(PokitDeleteBottomSheet.Delegate)
        }

        public enum DelegateAction: Equatable {
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped

            case categoryTapped(BaseCategoryItem)
            case 수정하기(BaseCategoryItem)
            case 링크수정하기(id: Int)
            /// 링크상세로 이동
            case contentDetailTapped(BaseContentItem)
            case 미분류_카테고리_컨텐츠_조회
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
private extension PokitRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
        /// - Navigation Bar
        case .검색_버튼_눌렀을때:
            return .run { send in await send(.delegate(.searchButtonTapped)) }
            
        case .알람_버튼_눌렀을때:
            return .run { send in await send(.delegate(.alertButtonTapped)) }
            
        case .설정_버튼_눌렀을때:
            return .run { send in await send(.delegate(.settingButtonTapped)) }

        case .필터_버튼_눌렀을때(let selectedFolderType):
            state.folderType = .folder(selectedFolderType)
            state.sortType = .sort(.최신순)
            return .send(.inner(.sort))
            
        case .분류_버튼_눌렀을때:
            switch state.folderType {
            case .folder(.포킷):
                state.sortType = .sort(state.sortType == .sort(.이름순) ? .최신순 : .이름순)
                return .send(.inner(.sort), animation: .pokitDissolve)
                
            case .folder(.미분류):
                state.sortType = .sort(state.sortType == .sort(.오래된순) ? .최신순 : .오래된순)
                return .send(.inner(.sort), animation: .pokitDissolve)
                
            default: return .none
            }

        case .케밥_버튼_눌렀을때(let selectedItem):
            state.selectedKebobItem = selectedItem
            return .run { send in await send(.inner(.카테고리_시트_활성화(true))) }

        case .미분류_케밥_버튼_눌렀을때(let selectedItem):
            state.selectedUnclassifiedItem = selectedItem
            return .run { send in await send(.inner(.카테고리_시트_활성화(true))) }

        case .카테고리_눌렀을때(let category):
            return .run { send in await send(.delegate(.categoryTapped(category))) }

            /// - 링크 아이템을 눌렀을 때
        case .컨텐츠_항목_눌렀을때(let selectedItem):
            return .run { send in await send(.delegate(.contentDetailTapped(selectedItem))) }
            
        case .뷰가_나타났을때:
            switch state.folderType {
            case .folder(.포킷):
                guard let _ = state.domain.categoryList.data?.count else {
                    return .send(.inner(.페이지네이션_초기화))
                }
                return .send(.async(.카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            case .folder(.미분류):
                guard let _ = state.domain.unclassifiedContentList.data?.count else {
                    return .send(.inner(.페이지네이션_초기화))
                }
                return .send(.async(.미분류_카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            default: return .none
            }
            
        case .페이지_로딩중일때:
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_페이징_조회_API))
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_페이징_조회_API))
                
            default: return .none
            }
            
        case .링크_공유_완료되었을때:
            state.shareSheetItem = nil
            return .none
        }
    }

    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_시트_활성화(presented):
            state.isKebobSheetPresented = presented
            return .none

        case let .카테고리_삭제_시트_활성화(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none

        case .sort:
            switch state.sortType {
            case .sort(.이름순):
                state.domain.pageable.sort = ["name,asc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            case .sort(.오래된순):
                state.domain.pageable.sort = ["createdAt,asc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            case .sort(.최신순):
                state.domain.pageable.sort = ["createdAt,desc"]
                return .send(.inner(.페이지네이션_초기화), animation: .pokitDissolve)
                
            default: return .none
            }

        case .미분류_카테고리_조회_API_반영(contentList: let contentList):
            state.domain.unclassifiedContentList = contentList
            return .none
            
        case let .카테고리_조회_API_반영(categoryList):
            state.domain.categoryList = categoryList
            return .none

        case let .카테고리_페이징_조회_API_반영(contentList):
            let list = state.domain.categoryList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.categoryList = contentList
            state.domain.categoryList.data = list + newList
            state.domain.pageable.size = 10
            return .none

        case let .미분류_카테고리_페이징_조회_API_반영(contentList):
            let list = state.domain.unclassifiedContentList.data ?? []
            guard let newList = contentList.data else { return .none }

            state.domain.unclassifiedContentList = contentList
            state.domain.unclassifiedContentList.data = list + newList
            state.domain.pageable.size = 10
            return .none
            
        case let .미분류_카테고리_컨텐츠_삭제_API_반영(contentId: contentId):
            guard let index = state.domain.unclassifiedContentList.data?.firstIndex(where: { $0.id == contentId }) else {
                return .none
            }
            state.domain.unclassifiedContentList.data?.remove(at: index)
            state.isPokitDeleteSheetPresented = false
            return .none
            
        case .페이지네이션_초기화:
            state.domain.pageable.page = 0
            state.domain.categoryList.data = nil
            state.domain.unclassifiedContentList.data = nil
            
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_조회_API), animation: .pokitDissolve)
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_조회_API), animation: .pokitDissolve)
                
            default: return .none
            }
        }
    }

    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .카테고리_삭제_API(categoryId):
            return .run { _ in try await categoryClient.카테고리_삭제(categoryId) }
            
        case .미분류_카테고리_페이징_조회_API:
            state.domain.pageable.page += 1
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(request).toDomain()
                await send(.inner(.미분류_카테고리_페이징_조회_API_반영(contentList: contentList)))
            }
            
        case .카테고리_페이징_조회_API:
            state.domain.pageable.page += 1
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let classified = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                await send(.inner(.카테고리_페이징_조회_API_반영(contentList: classified)))
            }
            
        case .미분류_카테고리_조회_API:
            state.domain.pageable.page = 0
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(request).toDomain()
                await send(.inner(.미분류_카테고리_조회_API_반영(contentList: contentList)), animation: .pokitSpring)
            }
            
        case .카테고리_조회_API:
            state.domain.pageable.page = 0
            return .run { [pageable = state.domain.pageable] send in
                let request = BasePageableRequest(page: pageable.page, size: pageable.size, sort: pageable.sort)
                let classified = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                await send(.inner(.카테고리_조회_API_반영(categoryList: classified)), animation: .pokitSpring)
            }
            
        case .미분류_카테고리_페이징_재조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let stream = AsyncThrowingStream<BaseContentListInquiry, Error> { continuation in
                    Task {
                        for page in 0...pageable.page {
                            let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(
                                BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                )
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
                await send(
                    .inner(.미분류_카테고리_조회_API_반영(contentList: contentItems)),
                    animation: .pokitSpring
                )
            }
            
        case .카테고리_페이징_재조회_API:
            return .run { [pageable = state.domain.pageable] send in
                let stream = AsyncThrowingStream<BaseCategoryListInquiry, Error> { continuation in
                    Task {
                        for page in 0...pageable.page {
                            let categoryList = try await categoryClient.카테고리_목록_조회(
                                BasePageableRequest(
                                    page: page,
                                    size: pageable.size,
                                    sort: pageable.sort
                                ),
                                true
                            ).toDomain()
                            continuation.yield(categoryList)
                        }
                        continuation.finish()
                    }
                }
                var categoryItems: BaseCategoryListInquiry? = nil
                for try await categoryList in stream {
                    let items = categoryItems?.data ?? []
                    let newItems = categoryList.data ?? []
                    categoryItems = categoryList
                    categoryItems?.data = items + newItems
                }
                guard let categoryItems else { return }
                await send(.inner(.카테고리_조회_API_반영(categoryList: categoryItems)), animation: .pokitSpring)
            }
            
        case let .미분류_카테고리_컨텐츠_삭제_API(contentId):
            return .run { send in
                let _ = try await contentClient.컨텐츠_삭제("\(contentId)")
                await send(.inner(.미분류_카테고리_컨텐츠_삭제_API_반영(contentId: contentId)), animation: .pokitSpring)
            }
            
        }
    }

    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - Kebob BottomSheet Delegate
        case .bottomSheet(.shareCellButtonTapped):
            /// Todo: 공유하기
            switch state.folderType {
            case .folder(.미분류):
                guard let selectedItem = state.selectedUnclassifiedItem else {
                    /// 🚨 Error Case [1]: 항목을 공유하려는데 항목이 없을 때
                    return .none
                }
                state.isKebobSheetPresented = false
                state.shareSheetItem = selectedItem
                return .none
            case .folder(.포킷):
                guard let selectedItem = state.selectedKebobItem else {
                    /// 🚨 Error Case [1]: 항목을 공유하려는데 항목이 없을 때
                    return .none
                }
                kakaoShareClient.카테고리_카카오톡_공유(
                    CategoryKaKaoShareModel(
                        categoryName: selectedItem.categoryName,
                        categoryId: selectedItem.id,
                        imageURL: selectedItem.categoryImage.imageURL
                    )
                )
                state.isKebobSheetPresented = false
                return .none

            default: return .none
            }

        case .bottomSheet(.editCellButtonTapped):
            switch state.folderType {
            case .folder(.미분류):
                state.isKebobSheetPresented = false
                return .run { [item = state.selectedUnclassifiedItem] send in
                    guard let item else { return }
                    await send(.delegate(.링크수정하기(id: item.id)))
                }

            case .folder(.포킷):
                /// [1] 케밥을 종료
                state.isKebobSheetPresented = false
                /// [2] 수정하기로 이동
                return .run { [item = state.selectedKebobItem] send in
                    guard let item else { return }
                    await send(.delegate(.수정하기(item)))
                }
            default: return .none
            }

        case .bottomSheet(.deleteCellButtonTapped):
            return .run { send in
                await send(.inner(.카테고리_시트_활성화(false)))
                await send(.inner(.카테고리_삭제_시트_활성화(true)))
            }

        /// - Pokit Delete BottomSheet Delegate
        case .deleteBottomSheet(.cancelButtonTapped):
            state.isPokitDeleteSheetPresented = false
            return .none

        case .deleteBottomSheet(.deleteButtonTapped):
            switch state.folderType {
            case .folder(.미분류):
                guard let selectedItem = state.selectedUnclassifiedItem else {
                    /// 🚨 Error Case [1]: 항목을 삭제하려는데 항목이 없을 때
                    return .none
                }

                return .send(.async(.미분류_카테고리_컨텐츠_삭제_API(contentId: selectedItem.id)), animation: .pokitSpring)

            case .folder(.포킷):
                guard let selectedItem = state.selectedKebobItem else {
                    /// 🚨 Error Case [1]: 항목을 삭제하려는데 항목이 없을 때
                    return .none
                }
                guard let index = state.domain.categoryList.data?.firstIndex(of: selectedItem) else {
                    return .none
                }
                state.domain.categoryList.data?.remove(at: index)
                state.isPokitDeleteSheetPresented = false

                return .run { send in await send(.async(.카테고리_삭제_API(categoryId: selectedItem.id))) }
                
            default: return .none
            }
            
        default: return .none
        }
    }

    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .미분류_카테고리_컨텐츠_조회:
            switch state.folderType {
            case .folder(.포킷):
                return .send(.async(.카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            case .folder(.미분류):
                return .send(.async(.미분류_카테고리_페이징_재조회_API), animation: .pokitSpring)
                
            default: return .none
            }
        default:
            return .none
        }
    }
}
